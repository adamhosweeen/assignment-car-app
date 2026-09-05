-- ═══ 0014 · auctions (module: bid) ═══════════════════════════════════════════
-- Replaces the one-off bid negotiation from 0009 with seller-run timed
-- auctions. The seller picks one of their `selling` cars, sets a starting
-- price, a minimum increment and a deadline; buyers then outbid each other
-- until the clock runs out, and the highest bid wins automatically.
--
-- Shape of the change:
--   * new `auctions` table, one running auction per car
--   * `bids` now belong to an auction, carry no contact details, and may be
--     placed repeatedly by the same person (the one-pending-bid unique index
--     goes); their status set becomes placed / won / lost
--   * every transition goes through a SECURITY DEFINER function, because RLS
--     cannot express "this amount must beat the current highest by at least
--     the increment" — so `bids` loses its INSERT policy entirely
--   * the seller's accept/reject step disappears: `withdraw_bid` and
--     `respond_to_bid` are dropped
--
-- Existing bids are deleted: they predate auctions and have nothing to belong
-- to.
--
-- SETTLEMENT WITHOUT A SCHEDULER. This project has no cron and the app must
-- never hold a service-role key, so `settle_due_auctions()` is written to be
-- called opportunistically — the app runs it before every auction read, so a
-- finished auction closes the first time anyone looks. If you want auctions to
-- close punctually with no traffic, enable pg_cron and add:
--   select cron.schedule('settle-auctions', '* * * * *',
--                        $$select public.settle_due_auctions()$$);
--
-- Depends on: 0001, 0009 (bids), 0012 (record_purchase), 0013 (the four
-- listing statuses). Additive: safe to paste on its own; re-runnable.

-- ─── Out with the old ────────────────────────────────────────────────────────
drop trigger if exists bids_notify_resolved on public.bids;
drop function if exists public.notify_bid_resolved() cascade;
drop function if exists public.withdraw_bid(uuid) cascade;
drop function if exists public.respond_to_bid(uuid, boolean) cascade;
drop policy if exists "bids_insert_own" on public.bids;
drop index if exists public.bids_one_pending_per_bidder;

delete from public.bids;

-- ─── auctions ────────────────────────────────────────────────────────────────
create table if not exists public.auctions (
  id                 uuid primary key default gen_random_uuid(),
  listing_id         uuid not null references public.listings (id) on delete cascade,
  seller_id          uuid not null references public.profiles (id) on delete cascade,
  starting_price_myr integer not null check (starting_price_myr > 0),
  min_increment_myr  integer not null check (min_increment_myr > 0),
  ends_at            timestamptz not null,
  status             text not null default 'running'
                       check (status in ('running', 'settled', 'cancelled')),
  -- Denormalised so every viewer can see the state of play. `bids` is
  -- own-or-seller by RLS, so a buyer cannot read anyone else's bid rows and
  -- could not otherwise compute the current top bid.
  highest_bid_myr    integer,
  bid_count          integer not null default 0,
  winning_bid_id     uuid,
  settled_at         timestamptz,
  created_at         timestamptz not null default now()
);

create unique index if not exists auctions_one_running_per_listing
  on public.auctions (listing_id) where status = 'running';
create index if not exists auctions_status_ends_idx
  on public.auctions (status, ends_at);

alter table public.auctions enable row level security;
drop policy if exists "auctions_select" on public.auctions;
create policy "auctions_select" on public.auctions
  for select to authenticated using (true);
-- No write policy: start_auction / place_bid / cancel_auction / settle own it.

-- ─── bids, reshaped ──────────────────────────────────────────────────────────
alter table public.bids
  add column if not exists auction_id uuid references public.auctions (id) on delete cascade;
alter table public.bids drop column if exists contact_phone;
alter table public.bids drop column if exists notify_whatsapp;

alter table public.bids drop constraint if exists bids_status_check;
alter table public.bids alter column status set default 'placed';
alter table public.bids
  add constraint bids_status_check check (status in ('placed', 'won', 'lost'));

create index if not exists bids_auction_amount_idx
  on public.bids (auction_id, amount_myr desc, created_at);

-- ─── Pending bids close when the car leaves the market (0013's version, with
-- ─── the new bid status names) ───────────────────────────────────────────────
create or replace function public.reject_bids_on_closed_listing()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  if new.status in ('hidden', 'sold')
     and old.status in ('selling', 'bidding') then
    update public.bids
       set status = 'lost'
     where listing_id = new.id
       and status = 'placed';
  end if;
  return new;
end;
$$;

-- ─── Notification kinds ──────────────────────────────────────────────────────
alter table public.notifications
  drop constraint if exists notifications_kind_check;
alter table public.notifications
  add constraint notifications_kind_check check (
    kind in (
      'welcome', 'listing_match', 'insights_updated',
      'bid_placed', 'bid_accepted', 'bid_rejected',
      'bid_outbid', 'auction_won', 'auction_ended'
    )
  );

-- ─── start_auction ───────────────────────────────────────────────────────────
create or replace function public.start_auction(
  p_listing_id       uuid,
  p_starting_price   integer,
  p_min_increment    integer,
  p_ends_at          timestamptz
)
returns uuid
language plpgsql
security definer set search_path = public
as $$
declare
  uid uuid := auth.uid();
  car record;
  new_id uuid;
begin
  if uid is null then
    raise exception 'not signed in';
  end if;
  if p_starting_price is null or p_starting_price <= 0 then
    raise exception 'Enter a starting price.';
  end if;
  if p_min_increment is null or p_min_increment <= 0 then
    raise exception 'Enter a minimum increment.';
  end if;
  if p_ends_at is null or p_ends_at <= now() then
    raise exception 'The auction must end in the future.';
  end if;
  if p_ends_at > now() + interval '7 days' then
    raise exception 'An auction can run for at most 7 days.';
  end if;

  select l.seller_id, l.status into car
    from public.listings l where l.id = p_listing_id;

  if not found then
    raise exception 'This listing is no longer available.';
  end if;
  if car.seller_id <> uid then
    raise exception 'You can only auction your own car.';
  end if;
  if car.status <> 'selling' then
    raise exception 'Only a car that is on sale can go to auction.';
  end if;

  insert into public.auctions
    (listing_id, seller_id, starting_price_myr, min_increment_myr, ends_at)
  values
    (p_listing_id, uid, p_starting_price, p_min_increment, p_ends_at)
  returning id into new_id;

  update public.listings set status = 'bidding' where id = p_listing_id;

  return new_id;
end;
$$;
revoke all on function public.start_auction(uuid, integer, integer, timestamptz)
  from public, anon;
grant execute on function public.start_auction(uuid, integer, integer, timestamptz)
  to authenticated;

-- ─── place_bid ───────────────────────────────────────────────────────────────
create or replace function public.place_bid(p_auction_id uuid, p_amount integer)
returns uuid
language plpgsql
security definer set search_path = public
as $$
declare
  uid       uuid := auth.uid();
  a         record;
  top       record;
  minimum   integer;
  new_id    uuid;
begin
  if uid is null then
    raise exception 'not signed in';
  end if;

  select au.id, au.listing_id, au.seller_id, au.status, au.ends_at,
         au.starting_price_myr, au.min_increment_myr
    into a
    from public.auctions au
   where au.id = p_auction_id
     for update;

  if not found then
    raise exception 'This auction is no longer available.';
  end if;
  if a.status <> 'running' or a.ends_at <= now() then
    raise exception 'This auction has ended.';
  end if;
  if a.seller_id = uid then
    raise exception 'You can’t bid on your own car.';
  end if;

  select b.bidder_id, b.amount_myr into top
    from public.bids b
   where b.auction_id = p_auction_id
   order by b.amount_myr desc, b.created_at asc
   limit 1;

  minimum := case
    when top.amount_myr is null then a.starting_price_myr
    else top.amount_myr + a.min_increment_myr
  end;

  if p_amount is null or p_amount < minimum then
    raise exception 'Bid at least RM %.', to_char(minimum, 'FM999,999,999');
  end if;

  insert into public.bids (listing_id, auction_id, bidder_id, amount_myr, status)
  values (a.listing_id, p_auction_id, uid, p_amount, 'placed')
  returning id into new_id;

  update public.auctions
     set highest_bid_myr = p_amount,
         bid_count = bid_count + 1
   where id = p_auction_id;

  if top.bidder_id is not null and top.bidder_id <> uid then
    insert into public.notifications (user_id, kind, title, body, listing_id, route)
    select top.bidder_id, 'bid_outbid', 'You have been outbid',
           'Someone bid RM ' || to_char(p_amount, 'FM999,999,999')
             || ' on the ' || l.year || ' ' || l.make || ' ' || l.model || '.',
           l.id, '/auction/' || p_auction_id
      from public.listings l where l.id = a.listing_id;
  end if;

  return new_id;
end;
$$;
revoke all on function public.place_bid(uuid, integer) from public, anon;
grant execute on function public.place_bid(uuid, integer) to authenticated;

-- ─── cancel_auction ──────────────────────────────────────────────────────────
create or replace function public.cancel_auction(p_auction_id uuid)
returns void
language plpgsql
security definer set search_path = public
as $$
declare
  uid uuid := auth.uid();
  a   record;
  bid_count integer;
begin
  if uid is null then
    raise exception 'not signed in';
  end if;

  select au.id, au.listing_id, au.seller_id, au.status into a
    from public.auctions au where au.id = p_auction_id for update;

  if not found then
    raise exception 'This auction is no longer available.';
  end if;
  if a.seller_id <> uid then
    raise exception 'Only the seller can cancel this auction.';
  end if;
  if a.status <> 'running' then
    raise exception 'This auction has already ended.';
  end if;

  select count(*) into bid_count from public.bids where auction_id = p_auction_id;
  if bid_count > 0 then
    raise exception 'Someone has already bid — this auction has to run its course.';
  end if;

  update public.auctions
     set status = 'cancelled', settled_at = now()
   where id = p_auction_id;

  update public.listings set status = 'selling'
   where id = a.listing_id and status = 'bidding';
end;
$$;
revoke all on function public.cancel_auction(uuid) from public, anon;
grant execute on function public.cancel_auction(uuid) to authenticated;

-- ─── settle_due_auctions ─────────────────────────────────────────────────────
-- Idempotent and safe to call from anywhere, by anyone: it only ever acts on
-- auctions whose deadline has already passed.
create or replace function public.settle_due_auctions()
returns integer
language plpgsql
security definer set search_path = public
as $$
declare
  a       record;
  winner  record;
  car     record;
  settled integer := 0;
begin
  for a in
    select id, listing_id, seller_id
      from public.auctions
     where status = 'running' and ends_at <= now()
     order by ends_at
     for update skip locked
  loop
    select l.make, l.model, l.year into car
      from public.listings l where l.id = a.listing_id;

    select b.id, b.bidder_id, b.amount_myr into winner
      from public.bids b
     where b.auction_id = a.id and b.status = 'placed'
     order by b.amount_myr desc, b.created_at asc
     limit 1;

    if winner.id is null then
      update public.auctions
         set status = 'settled', settled_at = now()
       where id = a.id;
      update public.listings set status = 'hidden'
       where id = a.listing_id and status = 'bidding';

      insert into public.notifications (user_id, kind, title, body, listing_id, route)
      values (
        a.seller_id, 'auction_ended', 'Your auction ended with no bids',
        coalesce(car.year || ' ' || car.make || ' ' || car.model, 'Your car')
          || ' is hidden now. Put it back on sale whenever you like.',
        a.listing_id, '/home/sell'
      );
    else
      -- Mark the winner first: flipping the listing fires
      -- reject_bids_on_closed_listing, which marks every still-'placed' bid lost.
      update public.bids set status = 'won' where id = winner.id;

      update public.auctions
         set status = 'settled', settled_at = now(), winning_bid_id = winner.id
       where id = a.id;

      update public.listings
         set status = 'sold', price_myr = winner.amount_myr
       where id = a.listing_id;

      perform public.record_purchase(
        a.listing_id, winner.bidder_id, winner.amount_myr, 'bid'
      );

      insert into public.notifications (user_id, kind, title, body, listing_id, route)
      values (
        winner.bidder_id, 'auction_won', 'You won the auction',
        'You won the '
          || coalesce(car.year || ' ' || car.make || ' ' || car.model, 'car')
          || ' at RM ' || to_char(winner.amount_myr, 'FM999,999,999') || '.',
        a.listing_id, '/profile/purchases'
      );

      insert into public.notifications (user_id, kind, title, body, listing_id, route)
      values (
        a.seller_id, 'auction_ended', 'Your auction sold',
        coalesce(car.year || ' ' || car.make || ' ' || car.model, 'Your car')
          || ' sold for RM ' || to_char(winner.amount_myr, 'FM999,999,999') || '.',
        a.listing_id, '/home/sell'
      );

      insert into public.notifications (user_id, kind, title, body, listing_id, route)
      select distinct b.bidder_id, 'auction_ended', 'Auction ended',
             'The '
               || coalesce(car.year || ' ' || car.make || ' ' || car.model, 'car')
               || ' went to a higher bid.',
             a.listing_id, '/home/bid'
        from public.bids b
       where b.auction_id = a.id and b.bidder_id <> winner.bidder_id;
    end if;

    settled := settled + 1;
  end loop;

  return settled;
end;
$$;
revoke all on function public.settle_due_auctions() from public, anon;
grant execute on function public.settle_due_auctions() to authenticated;

-- ─── Realtime ────────────────────────────────────────────────────────────────
do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'auctions'
  ) then
    alter publication supabase_realtime add table public.auctions;
  end if;
end $$;

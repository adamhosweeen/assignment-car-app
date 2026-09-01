-- ═══ 0009 · bids (module: bid) ════════════════════════════════════════════════
-- The bidding module. A signed-in user places a bid on somebody else's *active*
-- listing; the seller accepts or rejects it, the bidder may withdraw it while
-- it is still pending.
--
-- Accepting is the terminal action: it marks the winning bid 'accepted', every
-- other pending bid on that listing 'rejected', and flips the listing to 'sold'
-- at the winning amount — the same "sell at a negotiated price" shape as
-- `buy_at_offer` in 0008, so a car can never be sold twice.
--
-- Why SECURITY DEFINER for the transitions: a plain client-side update can only
-- be authorised by an RLS policy on the *row*, which cannot express "the seller
-- may set status to accepted/rejected but nothing else, and only from pending".
-- So `bids` gets SELECT + INSERT policies only, and every status change goes
-- through one of the three functions below. Same reasoning as 0004/0008.
--
-- Depends on: 0001 (listings, profiles, notifications), 0004 (established the
-- "flip an active listing to sold" pattern this mirrors).
-- Additive: safe to paste on its own; re-runnable.
--
-- SETUP.md step: "2l. Bids" pastes this file.

-- ─── bids ────────────────────────────────────────────────────────────────────
create table if not exists public.bids (
  id           uuid primary key default gen_random_uuid(),
  listing_id   uuid not null references public.listings (id) on delete cascade,
  bidder_id    uuid not null references public.profiles (id) on delete cascade,
  amount_myr   int  not null check (amount_myr > 0),
  status       text not null default 'pending'
                 check (status in ('pending', 'accepted', 'rejected', 'withdrawn')),
  -- Contact details captured on the bid form, so the seller can reach this
  -- bidder without exposing the whole (RLS-protected) profile row.
  contact_phone   text,
  notify_whatsapp bool not null default false,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);

-- Seller's "bids on my cars" list, newest first.
create index if not exists bids_listing_created_idx
  on public.bids (listing_id, created_at desc);
-- Bidder's "my bids" list, newest first.
create index if not exists bids_bidder_created_idx
  on public.bids (bidder_id, created_at desc);

-- At most one live bid per person per car. Re-bidding means withdrawing the
-- old one first (the app does this in one step); rejected/withdrawn/accepted
-- bids stay as history and do not block a new one.
create unique index if not exists bids_one_pending_per_bidder
  on public.bids (listing_id, bidder_id) where status = 'pending';

drop trigger if exists bids_set_updated_at on public.bids;
create trigger bids_set_updated_at
  before update on public.bids
  for each row execute function public.set_updated_at();

-- ─── RLS ─────────────────────────────────────────────────────────────────────
alter table public.bids enable row level security;

drop policy if exists "bids_select_own_or_seller" on public.bids;
drop policy if exists "bids_insert_own" on public.bids;

-- A bidder sees their own bids; a seller sees every bid on their own listings.
-- Nobody else sees a bid, so bidders cannot see each other's amounts.
create policy "bids_select_own_or_seller" on public.bids
  for select to authenticated using (
    bidder_id = auth.uid()
    or exists (
      select 1 from public.listings l
      where l.id = listing_id and l.seller_id = auth.uid()
    )
  );

-- You may only insert a bid as yourself, on somebody else's *active* listing.
-- The status/amount rules are enforced by the column checks above.
create policy "bids_insert_own" on public.bids
  for insert to authenticated with check (
    bidder_id = auth.uid()
    and status = 'pending'
    and exists (
      select 1 from public.listings l
      where l.id = listing_id
        and l.status = 'active'
        and l.seller_id <> auth.uid()
    )
  );

-- No UPDATE or DELETE policy: the three functions below own every transition,
-- and a bid is never deleted (withdrawn bids stay as the bidder's history).

-- ─── Transitions ─────────────────────────────────────────────────────────────

-- The bidder pulls their own bid back. Only from 'pending'.
create or replace function public.withdraw_bid(p_bid_id uuid)
returns void
language plpgsql
security definer set search_path = public
as $$
declare
  uid uuid := auth.uid();
  rec record;
begin
  if uid is null then
    raise exception 'not signed in';
  end if;

  select bd.id, bd.bidder_id, bd.status into rec
    from public.bids bd where bd.id = p_bid_id;

  if not found then
    raise exception 'Bid not found.';
  end if;
  if rec.bidder_id <> uid then
    raise exception 'Only the bidder can withdraw this bid.';
  end if;
  if rec.status <> 'pending' then
    raise exception 'This bid is no longer pending.';
  end if;

  update public.bids set status = 'withdrawn' where id = p_bid_id;
end;
$$;

revoke all on function public.withdraw_bid(uuid) from public;
grant execute on function public.withdraw_bid(uuid) to authenticated;

-- The seller accepts or rejects a pending bid on their own listing.
-- Accepting also rejects every other pending bid on that listing and sells the
-- car at the accepted amount (mirrors `buy_at_offer` in 0008).
create or replace function public.respond_to_bid(p_bid_id uuid, p_accept boolean)
returns void
language plpgsql
security definer set search_path = public
as $$
declare
  uid uuid := auth.uid();
  rec record;
begin
  if uid is null then
    raise exception 'not signed in';
  end if;

  select bd.id, bd.listing_id, bd.amount_myr, bd.status,
         l.seller_id, l.status as listing_status
    into rec
    from public.bids bd
    join public.listings l on l.id = bd.listing_id
   where bd.id = p_bid_id;

  if not found then
    raise exception 'Bid not found.';
  end if;
  if rec.seller_id <> uid then
    raise exception 'Only the seller can respond to this bid.';
  end if;
  if rec.status <> 'pending' then
    raise exception 'This bid is no longer pending.';
  end if;

  if not p_accept then
    update public.bids set status = 'rejected' where id = p_bid_id;
    return;
  end if;

  if rec.listing_status <> 'active' then
    raise exception 'This car is no longer available.';
  end if;

  update public.bids set status = 'accepted' where id = p_bid_id;

  -- Everyone else who was still waiting on this car loses.
  update public.bids
     set status = 'rejected'
   where listing_id = rec.listing_id
     and id <> p_bid_id
     and status = 'pending';

  update public.listings
     set status = 'sold', price_myr = rec.amount_myr
   where id = rec.listing_id
     and status = 'active';

  if not found then
    raise exception 'This car is no longer available.';
  end if;
end;
$$;

revoke all on function public.respond_to_bid(uuid, boolean) from public;
grant execute on function public.respond_to_bid(uuid, boolean) to authenticated;

-- A car that leaves the market by any other route (marked sold by the seller,
-- bought outright in checkout, soft-deleted) can't leave bids hanging as
-- 'pending' forever — they'd show as live in every bidder's list and the
-- unique index would keep blocking a fresh bid.
create or replace function public.reject_bids_on_closed_listing()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  if new.status <> 'active' and old.status = 'active' then
    update public.bids
       set status = 'rejected'
     where listing_id = new.id
       and status = 'pending';
  end if;
  return new;
end;
$$;

drop trigger if exists listings_reject_pending_bids on public.listings;
create trigger listings_reject_pending_bids
  after update of status on public.listings
  for each row execute function public.reject_bids_on_closed_listing();

-- ─── Notifications (module: notifications — kinds extended here) ─────────────
-- 0001 constrains `notifications.kind` to three values; bidding adds three
-- more. Per CONTRIBUTING §3.4 rule 4, changing an existing constraint is a
-- new file, not an edit to 0001.
alter table public.notifications
  drop constraint if exists notifications_kind_check;
alter table public.notifications
  add constraint notifications_kind_check check (
    kind in (
      'welcome', 'listing_match', 'insights_updated',
      'bid_placed', 'bid_accepted', 'bid_rejected'
    )
  );

-- bid_placed: tell the seller a new bid landed on their car.
create or replace function public.notify_bid_placed()
returns trigger
language plpgsql
security definer set search_path = public
as $$
declare
  l record;
begin
  select seller_id, make, model, year into l
    from public.listings where id = new.listing_id;
  if not found then
    return new;
  end if;

  insert into public.notifications (user_id, kind, title, body, listing_id, route)
  values (
    l.seller_id, 'bid_placed', 'New bid on your car',
    'Someone bid RM' || to_char(new.amount_myr, 'FM999,999,999') ||
      ' on your ' || l.year || ' ' || l.make || ' ' || l.model || '.',
    new.listing_id, '/home/bid'
  );
  return new;
end;
$$;

drop trigger if exists bids_notify_placed on public.bids;
create trigger bids_notify_placed
  after insert on public.bids
  for each row execute function public.notify_bid_placed();

-- bid_accepted / bid_rejected: tell the bidder how their bid ended. Withdrawn
-- is the bidder's own action, so it notifies nobody.
create or replace function public.notify_bid_resolved()
returns trigger
language plpgsql
security definer set search_path = public
as $$
declare
  l record;
  car text;
begin
  if new.status = old.status or new.status not in ('accepted', 'rejected') then
    return new;
  end if;

  select make, model, year into l
    from public.listings where id = new.listing_id;
  car := coalesce(l.year || ' ' || l.make || ' ' || l.model, 'the car');

  if new.status = 'accepted' then
    insert into public.notifications (user_id, kind, title, body, listing_id, route)
    values (
      new.bidder_id, 'bid_accepted', 'Your bid was accepted',
      'The seller accepted your RM' || to_char(new.amount_myr, 'FM999,999,999') ||
        ' bid on the ' || car || '. They will be in touch to arrange collection.',
      new.listing_id, '/home/bid'
    );
  else
    insert into public.notifications (user_id, kind, title, body, listing_id, route)
    values (
      new.bidder_id, 'bid_rejected', 'Your bid was not accepted',
      'Your RM' || to_char(new.amount_myr, 'FM999,999,999') ||
        ' bid on the ' || car || ' was not accepted.',
      new.listing_id, '/home/bid'
    );
  end if;
  return new;
end;
$$;

drop trigger if exists bids_notify_resolved on public.bids;
create trigger bids_notify_resolved
  after update of status on public.bids
  for each row execute function public.notify_bid_resolved();

-- ─── Realtime ────────────────────────────────────────────────────────────────
-- `add table` errors if it is already a member, so only add when it is not.
do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'bids'
  ) then
    alter publication supabase_realtime add table public.bids;
  end if;
end
$$;

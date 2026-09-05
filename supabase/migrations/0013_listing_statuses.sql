-- ═══ 0013 · listing statuses: selling / bidding / hidden / sold ══════════════
-- 0001 shipped `status in ('draft','active','sold','deleted')`. The bid module
-- rework needs a `bidding` state, and the other three names never matched what
-- they meant to a seller. The new set is:
--
--   selling  — live in the Buy feed (was 'active')
--   bidding  — an auction is running on it (new, see 0014)
--   hidden   — not visible to buyers: while photos upload during publish, and
--              when the seller takes the car off the market (was 'draft' and
--              'deleted', which are merged)
--   sold     — terminal, and now *undeletable* (see listings_delete_own below)
--
-- Deleting a listing becomes a real row delete rather than a status flip, so
-- there is no 'deleted' state to hide any more — except that a sold car is a
-- record of a real transaction and may never be removed.
--
-- Every policy, function and trigger that hard-codes 'active' is recreated
-- here. Note especially `reject_bids_on_closed_listing`: as written in 0009 it
-- rejects every pending bid whenever a listing leaves 'active', which would
-- fire the instant an auction starts. It now only fires when a car actually
-- leaves the market.
--
-- MUST ship together with the matching app build: `asEnumOrNull` in
-- lib/utils/json.dart throws on an unrecognised status, so an old client
-- reading 'selling' (or a new client reading 'active') fails to decode.
--
-- Depends on: 0001, 0003 (admin_user_stats), 0009 (bids), 0010
-- (notify_listing_match), 0011 (is_banned, listings_select), 0012 (the three
-- selling functions). Additive: safe to paste on its own; re-runnable.

-- ─── The column ──────────────────────────────────────────────────────────────
alter table public.listings drop constraint if exists listings_status_check;

update public.listings set status = 'hidden'  where status in ('draft', 'deleted');
update public.listings set status = 'selling' where status = 'active';

alter table public.listings
  add constraint listings_status_check
  check (status in ('selling', 'bidding', 'hidden', 'sold'));

alter table public.listings alter column status set default 'hidden';

-- ─── A sold car can never be deleted ─────────────────────────────────────────
-- Also blocks deleting a car mid-auction, which would pull the listing out
-- from under live bidders.
--
-- NOTE: `conversations.listing_id` is `on delete cascade` (0001:155), so a real
-- delete now takes every chat thread about that car with it. That is the price
-- of delete no longer being a status flip; hiding a car keeps everything.
-- `purchases.listing_id` is `on delete set null` (0012:34) and the row carries
-- a make/model/year snapshot, so a buyer's history survives regardless.
--
-- `delete_account()` is SECURITY DEFINER and bypasses RLS, so account deletion
-- still removes a user's sold cars.
drop policy if exists "listings_delete_own" on public.listings;
create policy "listings_delete_own" on public.listings
  for delete to authenticated
  using (seller_id = auth.uid() and status not in ('sold', 'bidding'));

-- Only start_auction / cancel_auction / settle_due_auctions (all SECURITY
-- DEFINER) may move a car into or out of `bidding`. A client editing or
-- marking-sold a car with a live auction is refused by the `using` half.
drop policy if exists "listings_update_own" on public.listings;
create policy "listings_update_own" on public.listings
  for update to authenticated
  using (seller_id = auth.uid() and status <> 'bidding')
  with check (seller_id = auth.uid() and status <> 'bidding');

-- A sold car's photos are part of the buyer's receipt: 0001's `for all` policy
-- let the seller delete them afterwards and gut the purchase history.
drop policy if exists "listing_media_write_own" on public.listing_media;
create policy "listing_media_write_own" on public.listing_media
  for all to authenticated
  using (
    exists (
      select 1 from public.listings l
      where l.id = listing_id
        and l.seller_id = auth.uid()
        and l.status <> 'sold'
    )
  )
  with check (
    exists (
      select 1 from public.listings l
      where l.id = listing_id
        and l.seller_id = auth.uid()
        and l.status <> 'sold'
    )
  );

-- ─── Visibility (was 0011) ───────────────────────────────────────────────────
-- Auction cars stay in the feed, so buyers can find them while bidding runs.
drop policy if exists "listings_select" on public.listings;
create policy "listings_select" on public.listings
  for select to authenticated
  using (
    seller_id = auth.uid()
    or (
      status in ('selling', 'bidding')
      and not public.is_banned(seller_id)
    )
  );

drop policy if exists "listing_media_select" on public.listing_media;
create policy "listing_media_select" on public.listing_media
  for select to authenticated
  using (
    exists (
      select 1 from public.listings l
      where l.id = listing_id
        and (
          l.seller_id = auth.uid()
          or (
            l.status in ('selling', 'bidding')
            and not public.is_banned(l.seller_id)
          )
        )
    )
  );

-- ─── Bids may only be placed on a car that is actually up for auction ────────
-- (0014 replaces this policy entirely with a SECURITY DEFINER place_bid().)
drop policy if exists "bids_insert_own" on public.bids;
create policy "bids_insert_own" on public.bids
  for insert to authenticated with check (
    bidder_id = auth.uid()
    and status = 'pending'
    and exists (
      select 1 from public.listings l
      where l.id = listing_id
        and l.status = 'bidding'
        and l.seller_id <> auth.uid()
    )
  );

-- ─── Pending bids only close when the car really leaves the market ───────────
-- 0009's version fired on any departure from 'active', which now includes
-- selling → bidding, i.e. the moment an auction begins.
create or replace function public.reject_bids_on_closed_listing()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  if new.status in ('hidden', 'sold')
     and old.status in ('selling', 'bidding') then
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

-- ─── Match notifications (was 0010) ──────────────────────────────────────────
-- Publish is now hidden → selling, so this still fires exactly once per car.
create or replace function public.notify_listing_match()
returns trigger
language plpgsql
security definer set search_path = public
as $$
declare
  p           record;
  makes       jsonb;
  bodies      jsonb;
  bmin        integer;
  bmax        integer;
  has_primary boolean;
  ok          boolean;
begin
  if new.status <> 'selling' then return new; end if;
  if tg_op = 'UPDATE' and old.status = 'selling' then return new; end if;

  for p in
    select id, state, interests from public.profiles where id <> new.seller_id
  loop
    makes  := coalesce(p.interests -> 'makes', '[]'::jsonb);
    bodies := coalesce(p.interests -> 'body_types', '[]'::jsonb);
    bmin   := (p.interests ->> 'budget_min_myr')::integer;
    bmax   := (p.interests ->> 'budget_max_myr')::integer;
    has_primary := jsonb_array_length(makes) > 0
                or jsonb_array_length(bodies) > 0
                or bmin is not null or bmax is not null;

    if not has_primary then
      continue;
    end if;

    ok := (jsonb_array_length(makes) = 0 or makes ? new.make)
      and (jsonb_array_length(bodies) = 0 or bodies ? new.body_type)
      and (bmin is null or new.price_myr >= bmin)
      and (bmax is null or new.price_myr <= bmax);

    if ok and not exists (
      select 1 from public.notifications n
      where n.user_id = p.id and n.listing_id = new.id
    ) then
      insert into public.notifications (user_id, kind, title, body, listing_id, route)
      values (
        p.id, 'listing_match', 'New car that matches your interests',
        new.year || ' ' || new.make || ' ' || new.model
          || ' · RM ' || to_char(new.price_myr, 'FM999,999,999')
          || ' · ' || new.state,
        new.id, '/listing/' || new.id
      );
    end if;
  end loop;
  return new;
end;
$$;

drop trigger if exists listings_notify_match on public.listings;
create trigger listings_notify_match
  after insert or update of status on public.listings
  for each row execute function public.notify_listing_match();

-- ─── Admin counts (was 0003): a car on auction is still listed ───────────────
create or replace function public.admin_user_stats()
returns table (
  id           uuid,
  display_name text,
  avatar_url   text,
  email        text,
  phone        text,
  dob          date,
  state        text,
  role         text,
  banned       boolean,
  created_at   timestamptz,
  active_count bigint,
  sold_count   bigint
)
language plpgsql stable
security definer set search_path = public
as $$
begin
  if not public.is_admin() then
    raise exception 'admin only' using errcode = '42501';
  end if;
  return query
    select
      p.id, p.display_name, p.avatar_url, p.email, p.phone, p.dob, p.state,
      p.role, p.banned, p.created_at,
      count(l.id) filter (where l.status in ('selling', 'bidding')) as active_count,
      count(l.id) filter (where l.status = 'sold')                  as sold_count
    from public.profiles p
    left join public.listings l on l.seller_id = p.id
    group by p.id
    order by p.created_at desc;
end;
$$;
revoke all on function public.admin_user_stats() from public, anon;
grant execute on function public.admin_user_stats() to authenticated;

-- ─── Selling a car (was 0012) ────────────────────────────────────────────────
-- All three guard `status = 'selling'` only: a car with a live auction cannot
-- be bought out from under the bidders.
create or replace function public.buy_listing(p_listing_id uuid)
returns void
language plpgsql
security definer set search_path = public
as $$
declare
  uid   uuid := auth.uid();
  paid  integer;
begin
  if uid is null then
    raise exception 'not signed in';
  end if;

  update public.listings
     set status = 'sold'
   where id = p_listing_id
     and status = 'selling'
  returning price_myr into paid;

  if not found then
    raise exception 'This car is no longer available.';
  end if;

  perform public.record_purchase(p_listing_id, uid, paid, 'buy_now');
end;
$$;
revoke all on function public.buy_listing(uuid) from public;
grant execute on function public.buy_listing(uuid) to authenticated;

create or replace function public.buy_at_offer(p_message_id uuid)
returns void
language plpgsql
security definer set search_path = public
as $$
declare
  uid uuid := auth.uid();
  msg record;
begin
  if uid is null then
    raise exception 'not signed in';
  end if;

  select m.id, m.message_type, m.offer_amount_myr, m.sender_id,
         m.offer_confirmed_at, c.buyer_id, c.listing_id
    into msg
    from public.messages m
    join public.conversations c on c.id = m.conversation_id
   where m.id = p_message_id;

  if not found then
    raise exception 'Message not found.';
  end if;
  if msg.message_type <> 'offer' or msg.offer_amount_myr is null then
    raise exception 'This message is not an offer.';
  end if;
  if uid <> msg.buyer_id then
    raise exception 'Only the buyer can complete this purchase.';
  end if;
  if msg.offer_confirmed_at is null and uid = msg.sender_id then
    raise exception 'Waiting for the seller to confirm this offer.';
  end if;

  update public.messages
     set offer_confirmed_at = coalesce(offer_confirmed_at, now())
   where id = p_message_id;

  update public.listings
     set status = 'sold', price_myr = msg.offer_amount_myr
   where id = msg.listing_id
     and status = 'selling';

  if not found then
    raise exception 'This car is no longer available.';
  end if;

  perform public.record_purchase(
    msg.listing_id, uid, msg.offer_amount_myr, 'chat_offer'
  );
end;
$$;
revoke all on function public.buy_at_offer(uuid) from public;
grant execute on function public.buy_at_offer(uuid) to authenticated;

-- Superseded by the auction settlement in 0014, but kept consistent here so
-- this migration leaves the database in a coherent state on its own.
create or replace function public.respond_to_bid(p_bid_id uuid, p_accept boolean)
returns void
language plpgsql
security definer set search_path = public
as $$
declare
  uid uuid := auth.uid();
  rec record;
begin
  select b.id, b.listing_id, b.bidder_id, b.amount_myr, b.status,
         l.seller_id, l.status as listing_status
    into rec
    from public.bids b
    join public.listings l on l.id = b.listing_id
   where b.id = p_bid_id;

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

  if rec.listing_status not in ('selling', 'bidding') then
    raise exception 'This car is no longer available.';
  end if;

  update public.bids set status = 'accepted' where id = p_bid_id;

  update public.bids
     set status = 'rejected'
   where listing_id = rec.listing_id
     and id <> p_bid_id
     and status = 'pending';

  update public.listings
     set status = 'sold', price_myr = rec.amount_myr
   where id = rec.listing_id
     and status in ('selling', 'bidding');

  if not found then
    raise exception 'This car is no longer available.';
  end if;

  perform public.record_purchase(
    rec.listing_id, rec.bidder_id, rec.amount_myr, 'bid'
  );
end;
$$;
revoke all on function public.respond_to_bid(uuid, boolean) from public;
grant execute on function public.respond_to_bid(uuid, boolean) to authenticated;

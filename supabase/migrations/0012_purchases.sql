-- ═══ 0012 · purchase history (module: buy) ═══════════════════════════════════
-- Until now nothing recorded *who* bought a car — every sale path just flipped
-- the listing to 'sold' (0004's own comment says as much). This adds the
-- receipt: one `purchases` row per completed sale, written by the same
-- SECURITY DEFINER functions that do the selling, so a buyer can look back at
-- what they bought.
--
-- Three paths sell a car and all three are replaced below:
--   buy_listing()    (0004) — "Buy now" at the asking price
--   buy_at_offer()   (0008) — buyer completes an agreed chat offer
--   respond_to_bid() (0009) — seller accepts a bid
--
-- `price_myr` is the amount actually paid, which is not always the listing's
-- asking price (a chat offer or an accepted bid rewrites it). make/model/year
-- are snapshotted so the history still reads correctly if the listing is later
-- edited, and still renders something if the seller deletes their account and
-- the listing goes with it (`listing_id` then becomes null).
--
-- Buyers also get read access to the listing they bought and its photos —
-- `listings_select` hides sold cars from everyone but the seller, so without
-- this the buyer's own history would be unable to show the car. Same
-- permissive-second-policy shape as 0007.
--
-- No backfill: sales made before this migration genuinely have no buyer
-- recorded, so history starts from here.
--
-- Depends on: 0001 (listings, profiles), 0004, 0008, 0009 (the functions
-- replaced here). Additive: safe to paste on its own; re-runnable.

create table if not exists public.purchases (
  id          uuid primary key default gen_random_uuid(),
  buyer_id    uuid not null references public.profiles (id) on delete cascade,
  seller_id   uuid not null references public.profiles (id) on delete cascade,
  listing_id  uuid references public.listings (id) on delete set null,
  price_myr   integer not null check (price_myr > 0),
  method      text not null check (method in ('buy_now', 'chat_offer', 'bid')),
  make        text not null,
  model       text not null,
  year        integer not null,
  created_at  timestamptz not null default now()
);

create index if not exists purchases_buyer_created_idx
  on public.purchases (buyer_id, created_at desc);

alter table public.purchases enable row level security;
drop policy if exists "purchases_select_own" on public.purchases;
create policy "purchases_select_own" on public.purchases
  for select to authenticated using (buyer_id = auth.uid());
-- No INSERT/UPDATE/DELETE policy: only the functions below write, and a
-- receipt is not something either side may rewrite.

-- A buyer keeps read access to the car they bought (and its photos), which
-- `listings_select` would otherwise deny once it is 'sold'.
drop policy if exists "listings_select_buyer" on public.listings;
create policy "listings_select_buyer" on public.listings
  for select to authenticated
  using (
    exists (
      select 1 from public.purchases p
      where p.listing_id = listings.id and p.buyer_id = auth.uid()
    )
  );

drop policy if exists "listing_media_select_buyer" on public.listing_media;
create policy "listing_media_select_buyer" on public.listing_media
  for select to authenticated
  using (
    exists (
      select 1 from public.purchases p
      where p.listing_id = listing_media.listing_id and p.buyer_id = auth.uid()
    )
  );

-- ─── Recording helper ────────────────────────────────────────────────────────
-- Snapshots the car off the listing row. Called from inside the selling
-- functions, after the listing has been flipped to 'sold'.
create or replace function public.record_purchase(
  p_listing_id uuid,
  p_buyer_id   uuid,
  p_price_myr  integer,
  p_method     text
)
returns void
language plpgsql
security definer set search_path = public
as $$
declare
  car record;
begin
  select l.seller_id, l.make, l.model, l.year
    into car
    from public.listings l
   where l.id = p_listing_id;

  if not found then
    return;
  end if;

  insert into public.purchases
    (buyer_id, seller_id, listing_id, price_myr, method, make, model, year)
  values
    (p_buyer_id, car.seller_id, p_listing_id, p_price_myr, p_method,
     car.make, car.model, car.year);
end;
$$;

revoke all on function public.record_purchase(uuid, uuid, integer, text)
  from public, anon, authenticated;

-- ─── 0004 · buy now ──────────────────────────────────────────────────────────
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
     and status = 'active'
  returning price_myr into paid;

  if not found then
    raise exception 'This car is no longer available.';
  end if;

  perform public.record_purchase(p_listing_id, uid, paid, 'buy_now');
end;
$$;

revoke all on function public.buy_listing(uuid) from public;
grant execute on function public.buy_listing(uuid) to authenticated;

-- ─── 0008 · buy at an agreed chat offer ──────────────────────────────────────
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
     and status = 'active';

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

-- ─── 0009 · seller accepts a bid ─────────────────────────────────────────────
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

  if rec.listing_status <> 'active' then
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
     and status = 'active';

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

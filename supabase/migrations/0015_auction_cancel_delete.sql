-- ═══ 0015 · cancel any live auction, delete finished ones (module: bid) ══════
-- 0014 let a seller cancel only while nobody had bid. That rule goes: the
-- seller may pull a running auction at any time. Every outstanding bid is
-- marked lost, each bidder is told, and the car returns to `selling`.
--
-- Sellers can also tidy their history: a settled or cancelled auction can be
-- deleted. Its bids go with it (`bids.auction_id` is `on delete cascade`).
-- A purchase the auction produced is untouched — `purchases` references the
-- listing, not the auction, and snapshots the car — so the buyer's receipt
-- survives. A running auction can never be deleted; cancel it first.
--
-- Depends on: 0014. Additive: safe to paste on its own; re-runnable.

create or replace function public.cancel_auction(p_auction_id uuid)
returns void
language plpgsql
security definer set search_path = public
as $$
declare
  uid uuid := auth.uid();
  a   record;
  car record;
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

  select l.make, l.model, l.year into car
    from public.listings l where l.id = a.listing_id;

  update public.auctions
     set status = 'cancelled', settled_at = now()
   where id = p_auction_id;

  update public.bids
     set status = 'lost'
   where auction_id = p_auction_id
     and status = 'placed';

  insert into public.notifications (user_id, kind, title, body, listing_id, route)
  select distinct b.bidder_id, 'auction_ended', 'Auction cancelled',
         'The seller cancelled the auction on the '
           || coalesce(car.year || ' ' || car.make || ' ' || car.model, 'car')
           || '. Your bid no longer stands.',
         a.listing_id, '/home/bid'
    from public.bids b
   where b.auction_id = p_auction_id;

  update public.listings set status = 'selling'
   where id = a.listing_id and status = 'bidding';
end;
$$;
revoke all on function public.cancel_auction(uuid) from public, anon;
grant execute on function public.cancel_auction(uuid) to authenticated;

create or replace function public.delete_auction(p_auction_id uuid)
returns void
language plpgsql
security definer set search_path = public
as $$
declare
  uid uuid := auth.uid();
  a   record;
begin
  if uid is null then
    raise exception 'not signed in';
  end if;

  select au.id, au.seller_id, au.status into a
    from public.auctions au where au.id = p_auction_id for update;

  if not found then
    raise exception 'This auction is no longer available.';
  end if;
  if a.seller_id <> uid then
    raise exception 'Only the seller can delete this auction.';
  end if;
  if a.status = 'running' then
    raise exception 'Cancel the auction before deleting it.';
  end if;

  delete from public.auctions where id = p_auction_id;
end;
$$;
revoke all on function public.delete_auction(uuid) from public, anon;
grant execute on function public.delete_auction(uuid) to authenticated;

-- ═══ 0002 · buy_listing (module: buy) ═════════════════════════════════════════
-- Dummy-checkout support. A buyer is not the seller, so the
-- "listings_update_own" RLS policy in 0001 silently blocks them from changing a
-- listing (the UPDATE matches zero rows and returns no error). This
-- SECURITY DEFINER function lets any signed-in user complete a purchase by
-- flipping an *active* listing to 'sold' — and only that transition.
-- Depends on: 0001. Additive: safe to paste on its own; re-runnable.
--
-- Note: for a real marketplace this would also record the buyer and take
-- payment. v1's buy flow is a demo, so it only removes the car from sale.

create or replace function public.buy_listing(p_listing_id uuid)
returns void
language plpgsql
security definer set search_path = public
as $$
begin
  if auth.uid() is null then
    raise exception 'not signed in';
  end if;

  update public.listings
     set status = 'sold'
   where id = p_listing_id
     and status = 'active';

  if not found then
    raise exception 'This car is no longer available.';
  end if;
end;
$$;

revoke all on function public.buy_listing(uuid) from public;
grant execute on function public.buy_listing(uuid) to authenticated;

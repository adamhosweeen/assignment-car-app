-- ═══ 0011 · banned sellers' listings really disappear (module: admin) ════════
-- 0003 tried to hide a banned seller's cars with a subquery inside the
-- `listings_select` policy:
--
--   and not exists (select 1 from public.profiles p
--                   where p.id = seller_id and p.banned)
--
-- That never worked. RLS applies to tables referenced *inside* a policy
-- expression, and `profiles_select_own` (0001) restricts `profiles` to
-- `id = auth.uid()`. So for any viewer looking at somebody else's listing the
-- subquery matches zero rows, `not exists` is always true, and the ban check
-- silently passes. The only account it could ever have filtered is the
-- seller's own, which the `seller_id = auth.uid()` branch already allows.
--
-- The fix is the same pattern `is_admin()` uses in 0002: read the flag through
-- a SECURITY DEFINER function, which runs as its owner and is not subject to
-- the caller's RLS. `listing_media_select` gets the mirror check so a banned
-- seller's photos are not reachable either.
--
-- Note: `listings_select_conversation_participant` (0007) still OR-exposes a
-- listing to the two people in a conversation about it, banned or not. That is
-- deliberate — it keeps an existing chat thread coherent — so a buyer who
-- already messaged the seller keeps seeing that one car.
--
-- Depends on: 0001 (listings, listing_media, profiles), 0003 (profiles.banned).
-- Additive: safe to paste on its own; re-runnable.

create or replace function public.is_banned(uid uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select coalesce((select p.banned from public.profiles p where p.id = uid), false);
$$;

revoke all on function public.is_banned(uuid) from public, anon;
grant execute on function public.is_banned(uuid) to authenticated;

drop policy if exists "listings_select" on public.listings;
create policy "listings_select" on public.listings
  for select to authenticated
  using (
    seller_id = auth.uid()
    or (status = 'active' and not public.is_banned(seller_id))
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
          or (l.status = 'active' and not public.is_banned(l.seller_id))
        )
    )
  );

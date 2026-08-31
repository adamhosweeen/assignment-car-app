-- Module: chat
-- Lets a conversation's buyer/seller keep seeing the listing (and its photos)
-- after it's marked sold or soft-deleted, instead of the row disappearing
-- from under the chat thread.
--
-- `listings_select` in 0001_init.sql only allows `status = 'active' or
-- seller_id = auth.uid()`. Once a seller marks their car sold, the buyer's
-- next `getById` (tapping the listing name in the chat header, or the thread
-- list) falls through both branches, gets zero rows back, and the app shows
-- the generic "This listing is no longer available." error — indistinguishable
-- from the listing having been deleted. 0001 is frozen, so this adds a second
-- permissive SELECT policy instead (Postgres OR-combines permissive policies
-- for the same command on the same table), scoped to only the two people in
-- an actual conversation about that listing. `listing_media` gets the mirror
-- policy for the same reason `listing_media_select` mirrors `listings_select`
-- in 0001 — otherwise the gallery comes back empty for the buyer.
--
-- SETUP.md step: "2g. Chat listing visibility" pastes this file.

drop policy if exists "listings_select_conversation_participant" on public.listings;
create policy "listings_select_conversation_participant" on public.listings
  for select to authenticated
  using (
    exists (
      select 1 from public.conversations c
      where c.listing_id = listings.id
        and (c.buyer_id = auth.uid() or c.seller_id = auth.uid())
    )
  );

drop policy if exists "listing_media_select_conversation_participant" on public.listing_media;
create policy "listing_media_select_conversation_participant" on public.listing_media
  for select to authenticated
  using (
    exists (
      select 1 from public.conversations c
      where c.listing_id = listing_media.listing_id
        and (c.buyer_id = auth.uid() or c.seller_id = auth.uid())
    )
  );

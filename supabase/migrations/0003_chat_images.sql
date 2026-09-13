-- ═══ CarSell · patch: chat images ═════════════════════════════════════════════
-- Incremental patch for a project that already has data — see SETUP.md §2a-bis.
-- Only adds a column, a bucket and two storage policies; never drops
-- anything, so it's safe to re-run.
--
-- Lets a participant send one photo per message (`message_type = 'image'`).
-- Reuses the same picker + compress pipeline as listing photos
-- (image_picker + flutter_image_compress); the only new piece is a private
-- `chat-media` storage bucket, scoped to the two people in the conversation
-- rather than "anyone signed in" the way listing-media is — a chat photo is a
-- private message, not a public listing photo.
--
-- A fresh project that runs 0001_schema.sql already has all of this —
-- running this patch afterwards changes nothing.

alter table public.messages
  drop constraint if exists messages_message_type_check;
alter table public.messages
  add constraint messages_message_type_check
    check (message_type in ('text', 'offer', 'image'));

alter table public.messages
  add column if not exists image_path text;

insert into storage.buckets (id, name, public)
values ('chat-media', 'chat-media', false)
on conflict (id) do nothing;

drop policy if exists "chat_media_read" on storage.objects;
create policy "chat_media_read" on storage.objects
  for select to authenticated using (
    bucket_id = 'chat-media' and exists (
      select 1 from public.conversations c
      where c.id = ((storage.foldername(name))[1])::uuid
        and (c.buyer_id = auth.uid() or c.seller_id = auth.uid())
    )
  );

drop policy if exists "chat_media_insert_participant" on storage.objects;
create policy "chat_media_insert_participant" on storage.objects
  for insert to authenticated with check (
    bucket_id = 'chat-media' and exists (
      select 1 from public.conversations c
      where c.id = ((storage.foldername(name))[1])::uuid
        and (c.buyer_id = auth.uid() or c.seller_id = auth.uid())
    )
  );

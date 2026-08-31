-- Module: chat
-- Enables realtime on conversations/messages and adds a read-receipt RPC.
--
-- The `messages_participants` policy in 0001_init.sql is `for all ... with check
-- (sender_id = auth.uid() and ...)`. `with check` also gates UPDATE, so a plain
-- client-side `update messages set read_at = ...` can only ever touch rows the
-- caller themselves sent — the opposite of what a read receipt needs (the
-- *recipient* marks the *sender's* message read). 0001 is frozen, so this is
-- fixed here with a SECURITY DEFINER function, the same pattern already used by
-- delete_account() in 0001.
--
-- SETUP.md step: "2f. Chat realtime + read receipts" pastes this file.

-- ─── Realtime ──────────────────────────────────────────────────────────────
-- `alter publication ... add table` errors if the table is already a member,
-- so guard each one to keep this file re-runnable.
do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'conversations'
  ) then
    alter publication supabase_realtime add table public.conversations;
  end if;

  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'messages'
  ) then
    alter publication supabase_realtime add table public.messages;
  end if;
end $$;

-- ─── Indexes ───────────────────────────────────────────────────────────────
create index if not exists conversations_buyer_idx
  on public.conversations (buyer_id);
create index if not exists conversations_seller_idx
  on public.conversations (seller_id);
create index if not exists messages_conversation_idx
  on public.messages (conversation_id, created_at);

-- ─── Read receipts ─────────────────────────────────────────────────────────
-- Marks every unread message in a conversation, sent by the OTHER participant,
-- as read by the caller. No-op (not an error) if the caller isn't a participant
-- or there's nothing unread.
create or replace function public.mark_conversation_read(p_conversation_id uuid)
returns void
language plpgsql
security definer set search_path = public
as $$
declare
  uid uuid := auth.uid();
begin
  if uid is null then
    raise exception 'not signed in';
  end if;
  update public.messages
     set read_at = now()
   where conversation_id = p_conversation_id
     and sender_id <> uid
     and read_at is null
     and exists (
       select 1 from public.conversations c
       where c.id = p_conversation_id
         and (c.buyer_id = uid or c.seller_id = uid)
     );
end;
$$;

revoke all on function public.mark_conversation_read(uuid) from public;
grant execute on function public.mark_conversation_read(uuid) to authenticated;

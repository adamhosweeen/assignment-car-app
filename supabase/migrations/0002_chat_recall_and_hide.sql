-- ═══ CarSell · patch: chat recall + hide conversation ════════════════════════
-- Incremental patch for a project that already has data — see SETUP.md §2a-bis.
-- Only adds columns/functions, never drops anything, so it's safe to re-run.
--
-- Adds three things to chat:
--   1. recall_message(uuid)    — the sender can withdraw their own message
--      within 2 minutes (an unconfirmed offer included). The row is kept with
--      `recalled_at` set; the client renders a "Message recalled" placeholder.
--   2. hide_conversation(uuid) — swipe-to-delete a thread from the Chat tab.
--      Affects only the caller's own view; a later message from either side
--      brings the thread back.
--   3. A trigger that makes last_message_at server-authoritative. It used to
--      be set by the client's own clock, which — compared against
--      buyer_deleted_at/seller_deleted_at (server `now()`) — could leave a
--      hidden thread stuck hidden even after a genuinely later message, if
--      the sender's device clock lagged the server's. If you already applied
--      an earlier version of this file (recall + hide but no trigger), re-run
--      it to pick up the fix.
--
-- A fresh project that runs 0001_schema.sql already has all three — running
-- this patch afterwards changes nothing.

alter table public.messages
  add column if not exists recalled_at timestamptz;

alter table public.conversations
  add column if not exists buyer_deleted_at  timestamptz,
  add column if not exists seller_deleted_at timestamptz;

create or replace function public.recall_message(p_message_id uuid)
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

  select m.sender_id, m.message_type, m.offer_confirmed_at,
         m.recalled_at, m.created_at
    into msg
    from public.messages m
    join public.conversations c on c.id = m.conversation_id
   where m.id = p_message_id
     and (c.buyer_id = uid or c.seller_id = uid);

  if not found then
    raise exception 'Message not found.';
  end if;
  if msg.sender_id <> uid then
    raise exception 'You can only recall your own messages.';
  end if;
  if msg.recalled_at is not null then
    raise exception 'This message has already been recalled.';
  end if;
  if msg.created_at < now() - interval '2 minutes' then
    raise exception 'This message can no longer be recalled.';
  end if;
  if msg.message_type = 'offer' and msg.offer_confirmed_at is not null then
    raise exception 'This offer has already been confirmed and can no longer be recalled.';
  end if;

  update public.messages set recalled_at = now() where id = p_message_id;
end;
$$;
revoke all on function public.recall_message(uuid) from public;
grant execute on function public.recall_message(uuid) to authenticated;

create or replace function public.hide_conversation(p_conversation_id uuid)
returns void
language plpgsql
security definer set search_path = public
as $$
declare
  uid  uuid := auth.uid();
  conv record;
begin
  if uid is null then
    raise exception 'not signed in';
  end if;

  select buyer_id, seller_id into conv
    from public.conversations
   where id = p_conversation_id;

  if not found then
    raise exception 'Conversation not found.';
  end if;
  if uid <> conv.buyer_id and uid <> conv.seller_id then
    raise exception 'not a participant';
  end if;

  if uid = conv.buyer_id then
    update public.conversations set buyer_deleted_at = now()
     where id = p_conversation_id;
  else
    update public.conversations set seller_deleted_at = now()
     where id = p_conversation_id;
  end if;
end;
$$;
revoke all on function public.hide_conversation(uuid) from public;
grant execute on function public.hide_conversation(uuid) to authenticated;

create or replace function public.touch_conversation_last_message()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  update public.conversations
     set last_message_at = new.created_at
   where id = new.conversation_id;
  return new;
end;
$$;

drop trigger if exists messages_touch_conversation on public.messages;
create trigger messages_touch_conversation
  after insert on public.messages
  for each row execute function public.touch_conversation_last_message();

-- Module: chat
-- Turns a chat "offer" message into something the other side can act on:
-- the recipient confirms it, and the buyer (only the buyer — they're the one
-- who actually purchases) completes the sale at the offered price.
--
-- Two directions, one buyer-only completion step:
--   * Seller sends an offer -> the buyer is the recipient. Confirming and
--     buying is one action for them (`buy_at_offer`): there's nothing left
--     for the seller to do once the buyer accepts.
--   * Buyer sends an offer -> the seller is the recipient, but a seller
--     can't buy their own listing. They call `confirm_offer` to accept the
--     price; the buyer then sees their own (now-confirmed) offer and calls
--     `buy_at_offer` to complete the purchase.
--
-- Both are SECURITY DEFINER, same reasoning as `mark_conversation_read` in
-- 0006: the frozen `messages_participants` policy in 0001 only lets the
-- *sender* of a message update it via a plain client-side update, which is
-- the wrong direction for both of these (the recipient confirms; the buyer,
-- who may or may not be the sender, completes the purchase).
--
-- Depends on: 0001 (conversations/messages/listings), 0004 (established the
-- "flip an active listing to sold" checkout pattern this mirrors — but this
-- sells at the confirmed offer's price, not the listing's list price, so
-- it's a new function rather than an edit to `buy_listing`).
-- Additive: safe to paste on its own; re-runnable.
--
-- SETUP.md step: "2k. Chat offer confirm + buy" pastes this file.

alter table public.messages
  add column if not exists offer_confirmed_at timestamptz;

-- The recipient of a buyer's offer (i.e. the seller) accepts the price.
-- Anyone but the message's own sender, who is a participant of its
-- conversation, may confirm it.
create or replace function public.confirm_offer(p_message_id uuid)
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
         c.buyer_id, c.seller_id
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
  if uid <> msg.buyer_id and uid <> msg.seller_id then
    raise exception 'not a participant';
  end if;
  if uid = msg.sender_id then
    raise exception 'You cannot confirm your own offer.';
  end if;

  update public.messages
     set offer_confirmed_at = coalesce(offer_confirmed_at, now())
   where id = p_message_id;
end;
$$;

revoke all on function public.confirm_offer(uuid) from public;
grant execute on function public.confirm_offer(uuid) to authenticated;

-- The buyer completes the sale at an offer's price. Confirms it first if
-- nobody has yet (the "seller offered, buyer accepts and buys in one tap"
-- case) — but if the buyer is the one who sent the offer, it must already
-- be confirmed by the seller (the "buyer offered, seller accepted, buyer
-- now completes" case). Mirrors `buy_listing` (0004) otherwise: only an
-- *active* listing can be sold this way, and the price recorded is the
-- offer's, not the listing's original list price.
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
end;
$$;

revoke all on function public.buy_at_offer(uuid) from public;
grant execute on function public.buy_at_offer(uuid) to authenticated;

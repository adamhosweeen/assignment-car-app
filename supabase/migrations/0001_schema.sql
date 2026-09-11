-- ═══ CarSell · consolidated schema ═══════════════════════════════════════════
-- The whole database in one file. Paste it into the Supabase SQL editor and
-- Run, then paste 0002_seed.sql. Both are safe to re-run.
--
-- ⚠️  FULL RESET. The preamble drops every app table, every auth account and
-- every function the app ever had (including ones from older layouts that no
-- longer exist), then rebuilds the final schema from scratch. Only ever point
-- it at a dev project. Uploaded images cannot be deleted from SQL — empty the
-- listing-media and avatars buckets in the dashboard if you want them gone.
--
-- Contents, in dependency order:
--   1. reset
--   2. users (+ role, banned), signup trigger
--   3. listings, listing_media, four-status model
--   4. conversations, messages, read receipts, offer confirm
--   5. auctions, bids
--   6. purchases
--   7. reports, admin RPCs, bans
--   8. selling paths (buy now / chat offer / auction settlement)
--   9. account deletion
--  10. inbox (welcome + listing-match triggers)
--  11. market insights (car_popularity table; data comes from 0002_seed.sql)
--  12. realtime + storage
--
-- Status model (listings.status): selling · bidding · hidden · sold.
-- Every state transition a client may not make directly is a SECURITY
-- DEFINER function; RLS on the tables is read-mostly and narrow.

-- ═══ 1. Reset ════════════════════════════════════════════════════════════════
-- legacy (renamed to public.users):
drop view  if exists public.public_profiles;
drop table if exists public.profiles      cascade;

drop table if exists public.purchases     cascade;
drop table if exists public.bids          cascade;
drop table if exists public.auctions      cascade;
drop table if exists public.reports       cascade;
-- legacy (the notifications feature was removed):
drop table if exists public.notifications cascade;
drop table if exists public.car_popularity cascade;
drop table if exists public.messages      cascade;
drop table if exists public.conversations cascade;
drop table if exists public.listing_media cascade;
drop table if exists public.listings      cascade;
drop table if exists public.users         cascade;
drop table if exists public.inbox         cascade;

drop trigger  if exists on_auth_user_created on auth.users;
drop function if exists public.handle_new_user()                 cascade;
drop function if exists public.set_updated_at()                  cascade;
drop function if exists public.notify_welcome()                  cascade;
drop function if exists public.notify_listing_match()            cascade;
drop function if exists public.notify_insights_updated()         cascade;
drop function if exists public.notify_bid_placed()               cascade;
drop function if exists public.notify_bid_resolved()             cascade;
drop function if exists public.reject_bids_on_closed_listing()   cascade;
drop function if exists public.protect_role()                    cascade;
drop function if exists public.is_admin()                        cascade;
drop function if exists public.is_banned(uuid)                   cascade;
drop function if exists public.admin_user_stats()                cascade;
drop function if exists public.admin_reports()                   cascade;
drop function if exists public.admin_resolve_report(uuid)        cascade;
drop function if exists public.admin_set_banned(uuid, boolean)   cascade;
drop function if exists public.delete_account()                  cascade;
drop function if exists public.mark_conversation_read(uuid)      cascade;
drop function if exists public.confirm_offer(uuid)               cascade;
drop function if exists public.buy_at_offer(uuid)                cascade;
drop function if exists public.buy_listing(uuid)                 cascade;
drop function if exists public.record_purchase(uuid, uuid, integer, text) cascade;
drop function if exists public.withdraw_bid(uuid)                cascade;
drop function if exists public.respond_to_bid(uuid, boolean)     cascade;
drop function if exists public.start_auction(uuid, integer, integer, timestamptz) cascade;
drop function if exists public.place_bid(uuid, integer)          cascade;
drop function if exists public.cancel_auction(uuid)              cascade;
drop function if exists public.delete_auction(uuid)              cascade;
drop function if exists public.settle_due_auctions()             cascade;

delete from auth.users;

drop policy if exists "listing_media_read"       on storage.objects;
drop policy if exists "listing_media_insert_own" on storage.objects;
drop policy if exists "listing_media_update_own" on storage.objects;
drop policy if exists "listing_media_delete_own" on storage.objects;
drop policy if exists "avatars_read"             on storage.objects;
drop policy if exists "avatars_insert_own"       on storage.objects;
drop policy if exists "avatars_update_own"       on storage.objects;
drop policy if exists "avatars_delete_own"       on storage.objects;

-- ═══ 2. Users ════════════════════════════════════════════════════════════════
create table public.users (
  id           uuid primary key references auth.users (id) on delete cascade,
  email        text,
  first_name   text,
  last_name    text,
  dob          date check (dob is null or dob <= (now() - interval '18 years')::date),
  phone        text,
  state        text,
  interests    jsonb   not null default '{}'::jsonb,
  display_name text generated always as (
                 nullif(trim(coalesce(first_name, '') || ' ' ||
                             coalesce(last_name, '')), '')
               ) stored,
  avatar_url   text,
  role         text    not null default 'customer'
                 check (role in ('customer', 'admin')),
  banned       boolean not null default false,
  created_at   timestamptz not null default now()
);

-- Mirror auth.users on signup. The registration payload rides in
-- raw_user_meta_data; this trigger is the only thing that inserts a profile,
-- so there is deliberately no INSERT policy for clients.
create function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.users
    (id, email, phone, first_name, last_name, dob, state, interests)
  values (
    new.id,
    new.email,
    new.raw_user_meta_data->>'phone',
    new.raw_user_meta_data->>'first_name',
    new.raw_user_meta_data->>'last_name',
    nullif(new.raw_user_meta_data->>'dob', '')::date,
    new.raw_user_meta_data->>'state',
    coalesce(new.raw_user_meta_data->'interests', '{}'::jsonb)
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- "Is the caller an admin?" — SECURITY DEFINER so it is safe inside policies.
create function public.is_admin()
returns boolean
language sql stable
security definer set search_path = public
as $$
  select exists (
    select 1 from public.users
    where id = auth.uid() and role = 'admin'
  );
$$;
revoke all on function public.is_admin() from public, anon;
grant execute on function public.is_admin() to authenticated;

-- "Is this user banned?" — MUST stay SECURITY DEFINER. users_select below
-- hides banned rows from everyone else, so an inline subquery here would find
-- no row for a banned seller, coalesce to false, and make their listings
-- visible again — the exact opposite of a ban.
create function public.is_banned(uid uuid)
returns boolean
language sql stable
security definer set search_path = public
as $$
  select coalesce((select u.banned from public.users u where u.id = uid), false);
$$;
revoke all on function public.is_banned(uuid) from public, anon;
grant execute on function public.is_banned(uuid) to authenticated;

-- Users may update their whole row, so without this they could promote
-- themselves. auth.uid() is null for dashboard sessions — those may always
-- change roles, which is how the first admin is seeded:
--   update public.users set role = 'admin' where email = 'you@example.com';
create function public.protect_role()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  if new.role is distinct from old.role
     and auth.uid() is not null
     and not public.is_admin() then
    raise exception 'only admins can change roles' using errcode = '42501';
  end if;
  return new;
end;
$$;

create trigger users_protect_role
  before update on public.users
  for each row execute function public.protect_role();

alter table public.users enable row level security;

-- Any signed-in user may read any user who is not banned — this is what backs
-- seller search and the public seller page. NOTE: this returns the whole row,
-- so email, phone, dob and interests are readable by other signed-in users.
-- To narrow it without reintroducing a view, add column-level grants:
--   revoke select on public.users from authenticated;
--   grant select (id, display_name, first_name, last_name, avatar_url,
--                 state, created_at, role, banned) on public.users
--     to authenticated;
-- (the app would then need an explicit column list in its select()).
create policy "users_select" on public.users
  for select to authenticated
  using (id = auth.uid() or not banned);
create policy "users_update_own" on public.users
  for update to authenticated
  using (id = auth.uid()) with check (id = auth.uid());

-- ═══ 3. Listings ═════════════════════════════════════════════════════════════
create table public.listings (
  id                   uuid primary key default gen_random_uuid(),
  seller_id            uuid not null references public.users (id),
  status               text not null default 'hidden'
                         check (status in ('selling', 'bidding', 'hidden', 'sold')),
  make                 text not null,
  model                text not null,
  variant              text,
  year                 int  not null check (year between 1970 and extract(year from now())::int + 1),
  mileage_km           int  not null check (mileage_km >= 0),
  transmission         text not null check (transmission in ('automatic', 'manual')),
  fuel_type            text not null check (fuel_type in ('petrol', 'diesel', 'hybrid', 'electric')),
  body_type            text not null check (body_type in ('sedan', 'hatchback', 'suv', 'mpv', 'pickup', 'coupe', 'other')),
  colour               text not null,
  owners_count         int  not null check (owners_count >= 1),
  accident_free        bool not null,
  road_tax_expiry      date,
  registration_region  text not null check (registration_region in ('west', 'east')),
  state                text not null,
  city                 text not null,
  price_myr            int  not null check (price_myr > 0),
  negotiable           bool not null default true,
  description          text check (char_length(description) <= 1000),
  created_at           timestamptz not null default now(),
  updated_at           timestamptz not null default now()
);

create index listings_status_created_idx on public.listings (status, created_at desc);
create index listings_seller_status_idx  on public.listings (seller_id, status);

create function public.set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger listings_set_updated_at
  before update on public.listings
  for each row execute function public.set_updated_at();

create table public.listing_media (
  id           uuid primary key default gen_random_uuid(),
  listing_id   uuid not null references public.listings (id) on delete cascade,
  storage_path text not null,
  media_type   text not null default 'photo' check (media_type in ('photo', 'video')),
  position     int  not null default 0,
  created_at   timestamptz not null default now()
);

create index listing_media_listing_idx on public.listing_media (listing_id, position);

alter table public.listings      enable row level security;
alter table public.listing_media enable row level security;

-- Cars on the market are visible to everyone except a banned seller's; a
-- seller always sees their own.
create policy "listings_select" on public.listings
  for select to authenticated
  using (
    seller_id = auth.uid()
    or (status in ('selling', 'bidding') and not public.is_banned(seller_id))
  );
create policy "listings_insert_own" on public.listings
  for insert to authenticated with check (seller_id = auth.uid());
-- Only the auction functions may move a car into or out of `bidding`.
create policy "listings_update_own" on public.listings
  for update to authenticated
  using (seller_id = auth.uid() and status <> 'bidding')
  with check (seller_id = auth.uid() and status <> 'bidding');
-- A sold car is a record of a real transaction; a bidding car has live
-- bidders. Neither can be deleted. Note conversations cascade on delete.
create policy "listings_delete_own" on public.listings
  for delete to authenticated
  using (seller_id = auth.uid() and status not in ('sold', 'bidding'));

create policy "listing_media_select" on public.listing_media
  for select to authenticated
  using (
    exists (
      select 1 from public.listings l
      where l.id = listing_id
        and (
          l.seller_id = auth.uid()
          or (l.status in ('selling', 'bidding') and not public.is_banned(l.seller_id))
        )
    )
  );
-- A sold car's photos are part of the buyer's receipt.
create policy "listing_media_write_own" on public.listing_media
  for all to authenticated
  using (
    exists (
      select 1 from public.listings l
      where l.id = listing_id and l.seller_id = auth.uid() and l.status <> 'sold'
    )
  )
  with check (
    exists (
      select 1 from public.listings l
      where l.id = listing_id and l.seller_id = auth.uid() and l.status <> 'sold'
    )
  );

-- ═══ 4. Chat ═════════════════════════════════════════════════════════════════
create table public.conversations (
  id              uuid primary key default gen_random_uuid(),
  listing_id      uuid not null references public.listings (id) on delete cascade,
  buyer_id        uuid not null references public.users (id),
  seller_id       uuid not null references public.users (id),
  created_at      timestamptz not null default now(),
  last_message_at timestamptz,
  unique (listing_id, buyer_id)
);

create table public.messages (
  id                 uuid primary key default gen_random_uuid(),
  conversation_id    uuid not null references public.conversations (id) on delete cascade,
  sender_id          uuid not null references public.users (id),
  body               text,
  message_type       text not null default 'text' check (message_type in ('text', 'offer')),
  offer_amount_myr   int,
  offer_confirmed_at timestamptz,
  created_at         timestamptz not null default now(),
  read_at            timestamptz
);

create index conversations_buyer_idx   on public.conversations (buyer_id);
create index conversations_seller_idx  on public.conversations (seller_id);
create index messages_conversation_idx on public.messages (conversation_id, created_at);

alter table public.conversations enable row level security;
alter table public.messages      enable row level security;

create policy "conversations_participants" on public.conversations
  for all to authenticated
  using (buyer_id = auth.uid() or seller_id = auth.uid())
  with check (buyer_id = auth.uid() or seller_id = auth.uid());
create policy "messages_participants" on public.messages
  for all to authenticated
  using (
    exists (
      select 1 from public.conversations c
      where c.id = conversation_id
        and (c.buyer_id = auth.uid() or c.seller_id = auth.uid())
    )
  )
  with check (
    sender_id = auth.uid() and exists (
      select 1 from public.conversations c
      where c.id = conversation_id
        and (c.buyer_id = auth.uid() or c.seller_id = auth.uid())
    )
  );

-- The two people in a conversation keep seeing the car (and its photos)
-- after it is sold or hidden, so the thread never loses its subject.
create policy "listings_select_conversation_participant" on public.listings
  for select to authenticated
  using (
    exists (
      select 1 from public.conversations c
      where c.listing_id = listings.id
        and (c.buyer_id = auth.uid() or c.seller_id = auth.uid())
    )
  );
create policy "listing_media_select_conversation_participant" on public.listing_media
  for select to authenticated
  using (
    exists (
      select 1 from public.conversations c
      where c.listing_id = listing_media.listing_id
        and (c.buyer_id = auth.uid() or c.seller_id = auth.uid())
    )
  );

-- The messages policy only lets a *sender* update their own message, which is
-- the wrong direction for a read receipt (the recipient marks it read).
create function public.mark_conversation_read(p_conversation_id uuid)
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

-- The recipient of an offer accepts its price. Anyone but the sender who is a
-- participant may confirm.
create function public.confirm_offer(p_message_id uuid)
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

-- ═══ 5. Auctions ═════════════════════════════════════════════════════════════
-- A seller puts one of their `selling` cars up for a timed auction. Buyers
-- outbid each other; each bid must beat the highest by the increment (the
-- first must reach the starting price). At the deadline the highest bid wins
-- automatically. RLS cannot express "beat the current highest", so every
-- write goes through a function and `bids` has no INSERT policy at all.
create table public.auctions (
  id                 uuid primary key default gen_random_uuid(),
  listing_id         uuid not null references public.listings (id) on delete cascade,
  seller_id          uuid not null references public.users (id) on delete cascade,
  starting_price_myr integer not null check (starting_price_myr > 0),
  min_increment_myr  integer not null check (min_increment_myr > 0),
  ends_at            timestamptz not null,
  status             text not null default 'running'
                       check (status in ('running', 'settled', 'cancelled')),
  -- Denormalised so every viewer sees the state of play: bids themselves are
  -- own-or-seller by RLS, so a buyer cannot compute the top bid from them.
  highest_bid_myr    integer,
  bid_count          integer not null default 0,
  winning_bid_id     uuid,
  settled_at         timestamptz,
  created_at         timestamptz not null default now()
);

create unique index auctions_one_running_per_listing
  on public.auctions (listing_id) where status = 'running';
create index auctions_status_ends_idx on public.auctions (status, ends_at);

create table public.bids (
  id          uuid primary key default gen_random_uuid(),
  listing_id  uuid not null references public.listings (id) on delete cascade,
  auction_id  uuid not null references public.auctions (id) on delete cascade,
  bidder_id   uuid not null references public.users (id) on delete cascade,
  amount_myr  int  not null check (amount_myr > 0),
  status      text not null default 'placed' check (status in ('placed', 'won', 'lost')),
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create index bids_listing_created_idx on public.bids (listing_id, created_at desc);
create index bids_bidder_created_idx  on public.bids (bidder_id, created_at desc);
create index bids_auction_amount_idx  on public.bids (auction_id, amount_myr desc, created_at);

create trigger bids_set_updated_at
  before update on public.bids
  for each row execute function public.set_updated_at();

alter table public.auctions enable row level security;
alter table public.bids     enable row level security;

create policy "auctions_select" on public.auctions
  for select to authenticated using (true);

-- A bidder sees their own bids; a seller sees every bid on their own cars.
-- Nobody else does, so bidders cannot see each other's amounts.
create policy "bids_select_own_or_seller" on public.bids
  for select to authenticated using (
    bidder_id = auth.uid()
    or exists (
      select 1 from public.listings l
      where l.id = listing_id and l.seller_id = auth.uid()
    )
  );

-- When a car leaves the market by any route, its outstanding bids are lost.
create function public.reject_bids_on_closed_listing()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  if new.status in ('hidden', 'sold')
     and old.status in ('selling', 'bidding') then
    update public.bids
       set status = 'lost'
     where listing_id = new.id
       and status = 'placed';
  end if;
  return new;
end;
$$;

create trigger listings_reject_pending_bids
  after update of status on public.listings
  for each row execute function public.reject_bids_on_closed_listing();

-- ═══ 6. Purchases ════════════════════════════════════════════════════════════
-- One row per completed sale, written only by the selling functions below.
-- price_myr is what was actually paid; make/model/year are snapshotted so the
-- receipt survives the listing being edited or removed (listing_id goes null)
-- and the seller closing their account (seller_id goes null).
create table public.purchases (
  id          uuid primary key default gen_random_uuid(),
  buyer_id    uuid not null references public.users (id) on delete cascade,
  -- set null, not cascade: if the SELLER closes their account the buyer keeps
  -- the receipt (the make/model/year snapshot below is what renders it).
  -- buyer_id DOES cascade — your own history goes with you.
  seller_id   uuid references public.users (id) on delete set null,
  listing_id  uuid references public.listings (id) on delete set null,
  price_myr   integer not null check (price_myr > 0),
  method      text not null check (method in ('buy_now', 'chat_offer', 'bid')),
  make        text not null,
  model       text not null,
  year        integer not null,
  created_at  timestamptz not null default now()
);

create index purchases_buyer_created_idx on public.purchases (buyer_id, created_at desc);

alter table public.purchases enable row level security;

create policy "purchases_select_own" on public.purchases
  for select to authenticated using (buyer_id = auth.uid());
-- No write policy: a receipt is not something either side may rewrite.

-- A buyer keeps read access to the car they bought and its photos, which
-- listings_select would otherwise deny once it is sold.
create policy "listings_select_buyer" on public.listings
  for select to authenticated
  using (
    exists (
      select 1 from public.purchases p
      where p.listing_id = listings.id and p.buyer_id = auth.uid()
    )
  );
create policy "listing_media_select_buyer" on public.listing_media
  for select to authenticated
  using (
    exists (
      select 1 from public.purchases p
      where p.listing_id = listing_media.listing_id and p.buyer_id = auth.uid()
    )
  );

create function public.record_purchase(
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

-- ═══ 7. Reports, admin, bans ═════════════════════════════════════════════════
create table public.reports (
  id           uuid primary key default gen_random_uuid(),
  reporter_id  uuid not null references public.users (id) on delete cascade,
  reported_id  uuid not null references public.users (id) on delete cascade,
  title        text not null check (char_length(trim(title)) between 1 and 80),
  description  text not null check (char_length(trim(description)) between 1 and 500),
  status       text not null default 'open' check (status in ('open', 'resolved')),
  created_at   timestamptz not null default now()
);

create index reports_status_created_idx on public.reports (status, created_at desc);

alter table public.reports enable row level security;

-- Users file reports as themselves, not against themselves. Only admins read,
-- via admin_reports().
create policy "reports_insert_own" on public.reports
  for insert to authenticated
  with check (reporter_id = auth.uid() and reporter_id <> reported_id);

-- Every user with their listing counts. Returns a full users row so the app
-- decodes it with the ordinary AppUser model — this column list must stay in
-- sync with AppUser.fromJson. It is also the ONLY way the admin screen sees
-- BANNED users: users_select hides them, this SECURITY DEFINER function does
-- not. Do not "simplify" the admin list to a plain select on users.
create function public.admin_user_stats()
returns table (
  id           uuid,
  email        text,
  first_name   text,
  last_name    text,
  display_name text,
  avatar_url   text,
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
      p.id, p.email, p.first_name, p.last_name, p.display_name, p.avatar_url,
      p.phone, p.dob, p.state, p.role, p.banned, p.created_at,
      count(l.id) filter (where l.status in ('selling', 'bidding')) as active_count,
      count(l.id) filter (where l.status = 'sold')                  as sold_count
    from public.users p
    left join public.listings l on l.seller_id = p.id
    group by p.id
    order by p.created_at desc;
end;
$$;
revoke all on function public.admin_user_stats() from public, anon;
grant execute on function public.admin_user_stats() to authenticated;

create function public.admin_reports()
returns table (
  id              uuid,
  reporter_id     uuid,
  reported_id     uuid,
  reporter_name   text,
  reported_name   text,
  reported_banned boolean,
  title           text,
  description     text,
  status          text,
  created_at      timestamptz
)
language plpgsql stable
security definer set search_path = public
as $$
begin
  if not public.is_admin() then
    raise exception 'admin only' using errcode = '42501';
  end if;
  return query
    select r.id, r.reporter_id, r.reported_id,
           pr.display_name, pd.display_name, pd.banned,
           r.title, r.description, r.status, r.created_at
    from public.reports r
    left join public.users pr on pr.id = r.reporter_id
    left join public.users pd on pd.id = r.reported_id
    order by r.created_at desc;
end;
$$;
revoke all on function public.admin_reports() from public, anon;
grant execute on function public.admin_reports() to authenticated;

create function public.admin_resolve_report(report_id uuid)
returns void
language plpgsql
security definer set search_path = public
as $$
begin
  if not public.is_admin() then
    raise exception 'admin only' using errcode = '42501';
  end if;
  update public.reports set status = 'resolved' where id = report_id;
end;
$$;
revoke all on function public.admin_resolve_report(uuid) from public, anon;
grant execute on function public.admin_resolve_report(uuid) to authenticated;

-- banned_until = 'infinity' makes GoTrue refuse logins and token refreshes,
-- so the ban holds without the service-role key ever reaching the app.
-- profiles.banned mirrors it so RLS and the admin UI can read it cheaply.
create function public.admin_set_banned(target uuid, ban boolean)
returns void
language plpgsql
security definer set search_path = public
as $$
begin
  if not public.is_admin() then
    raise exception 'admin only' using errcode = '42501';
  end if;
  if target = auth.uid() then
    raise exception 'you cannot ban yourself' using errcode = '42501';
  end if;
  if ban and exists (
    select 1 from public.users where id = target and role = 'admin'
  ) then
    raise exception 'admins cannot be banned' using errcode = '42501';
  end if;
  update auth.users
    set banned_until = case when ban then 'infinity'::timestamptz end
    where id = target;
  update public.users set banned = ban where id = target;
end;
$$;
revoke all on function public.admin_set_banned(uuid, boolean) from public, anon;
grant execute on function public.admin_set_banned(uuid, boolean) to authenticated;

-- ═══ 8. Selling a car ════════════════════════════════════════════════════════
-- Three routes sell a car and each records the purchase. All three guard
-- `status = 'selling'`: a car with a live auction cannot be bought outright.

-- Buy now, at the asking price.
create function public.buy_listing(p_listing_id uuid)
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

-- The buyer completes the sale at an agreed chat offer's price. Confirms it
-- first if nobody has yet; a buyer's own offer must already be confirmed by
-- the seller.
create function public.buy_at_offer(p_message_id uuid)
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

create function public.start_auction(
  p_listing_id       uuid,
  p_starting_price   integer,
  p_min_increment    integer,
  p_ends_at          timestamptz
)
returns uuid
language plpgsql
security definer set search_path = public
as $$
declare
  uid uuid := auth.uid();
  car record;
  new_id uuid;
begin
  if uid is null then
    raise exception 'not signed in';
  end if;
  if p_starting_price is null or p_starting_price <= 0 then
    raise exception 'Enter a starting price.';
  end if;
  if p_min_increment is null or p_min_increment <= 0 then
    raise exception 'Enter a minimum increment.';
  end if;
  if p_ends_at is null or p_ends_at <= now() then
    raise exception 'The auction must end in the future.';
  end if;
  if p_ends_at > now() + interval '7 days' then
    raise exception 'An auction can run for at most 7 days.';
  end if;

  select l.seller_id, l.status into car
    from public.listings l where l.id = p_listing_id;

  if not found then
    raise exception 'This listing is no longer available.';
  end if;
  if car.seller_id <> uid then
    raise exception 'You can only auction your own car.';
  end if;
  if car.status <> 'selling' then
    raise exception 'Only a car that is on sale can go to auction.';
  end if;

  insert into public.auctions
    (listing_id, seller_id, starting_price_myr, min_increment_myr, ends_at)
  values
    (p_listing_id, uid, p_starting_price, p_min_increment, p_ends_at)
  returning id into new_id;

  update public.listings set status = 'bidding' where id = p_listing_id;

  return new_id;
end;
$$;
revoke all on function public.start_auction(uuid, integer, integer, timestamptz)
  from public, anon;
grant execute on function public.start_auction(uuid, integer, integer, timestamptz)
  to authenticated;

-- The row lock on the auction serialises simultaneous bids, so the second
-- always sees the first's amount.
create function public.place_bid(p_auction_id uuid, p_amount integer)
returns uuid
language plpgsql
security definer set search_path = public
as $$
declare
  uid       uuid := auth.uid();
  a         record;
  top       record;
  minimum   integer;
  new_id    uuid;
begin
  if uid is null then
    raise exception 'not signed in';
  end if;

  select au.id, au.listing_id, au.seller_id, au.status, au.ends_at,
         au.starting_price_myr, au.min_increment_myr
    into a
    from public.auctions au
   where au.id = p_auction_id
     for update;

  if not found then
    raise exception 'This auction is no longer available.';
  end if;
  if a.status <> 'running' or a.ends_at <= now() then
    raise exception 'This auction has ended.';
  end if;
  if a.seller_id = uid then
    raise exception 'You can’t bid on your own car.';
  end if;

  select b.bidder_id, b.amount_myr into top
    from public.bids b
   where b.auction_id = p_auction_id
   order by b.amount_myr desc, b.created_at asc
   limit 1;

  minimum := case
    when top.amount_myr is null then a.starting_price_myr
    else top.amount_myr + a.min_increment_myr
  end;

  if p_amount is null or p_amount < minimum then
    raise exception 'Bid at least RM %.', to_char(minimum, 'FM999,999,999');
  end if;

  insert into public.bids (listing_id, auction_id, bidder_id, amount_myr, status)
  values (a.listing_id, p_auction_id, uid, p_amount, 'placed')
  returning id into new_id;

  update public.auctions
     set highest_bid_myr = p_amount,
         bid_count = bid_count + 1
   where id = p_auction_id;

  return new_id;
end;
$$;
revoke all on function public.place_bid(uuid, integer) from public, anon;
grant execute on function public.place_bid(uuid, integer) to authenticated;

-- The seller may pull a running auction at any time. Every outstanding bid is
-- lost, each bidder is told, and the car goes back on sale.
create function public.cancel_auction(p_auction_id uuid)
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

  update public.auctions
     set status = 'cancelled', settled_at = now()
   where id = p_auction_id;

  update public.bids
     set status = 'lost'
   where auction_id = p_auction_id
     and status = 'placed';

  update public.listings set status = 'selling'
   where id = a.listing_id and status = 'bidding';
end;
$$;
revoke all on function public.cancel_auction(uuid) from public, anon;
grant execute on function public.cancel_auction(uuid) to authenticated;

-- A settled or cancelled auction can be removed from the seller's history.
-- Its bids go with it; a purchase it produced references the listing, not
-- the auction, so the buyer's receipt survives.
create function public.delete_auction(p_auction_id uuid)
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

-- Settles every auction whose deadline has passed. Idempotent and safe for
-- any signed-in user to call: the app runs it before each auction read, so a
-- finished auction closes the first time anyone looks. `skip locked` means
-- two clients calling at once cannot both settle the same auction.
--
-- There is no scheduler. For punctual closing with no traffic, enable pg_cron
-- and add:
--   select cron.schedule('settle-auctions', '* * * * *',
--                        $$select public.settle_due_auctions()$$);
create function public.settle_due_auctions()
returns integer
language plpgsql
security definer set search_path = public
as $$
declare
  a       record;
  winner  record;
  settled integer := 0;
begin
  for a in
    select id, listing_id, seller_id
      from public.auctions
     where status = 'running' and ends_at <= now()
     order by ends_at
     for update skip locked
  loop
    select b.id, b.bidder_id, b.amount_myr into winner
      from public.bids b
     where b.auction_id = a.id and b.status = 'placed'
     order by b.amount_myr desc, b.created_at asc
     limit 1;

    if winner.id is null then
      update public.auctions
         set status = 'settled', settled_at = now()
       where id = a.id;
      update public.listings set status = 'hidden'
       where id = a.listing_id and status = 'bidding';
    else
      -- Mark the winner first: flipping the listing fires
      -- reject_bids_on_closed_listing, which marks every still-'placed' bid lost.
      update public.bids set status = 'won' where id = winner.id;

      update public.auctions
         set status = 'settled', settled_at = now(), winning_bid_id = winner.id
       where id = a.id;

      update public.listings
         set status = 'sold', price_myr = winner.amount_myr
       where id = a.listing_id;

      perform public.record_purchase(
        a.listing_id, winner.bidder_id, winner.amount_myr, 'bid'
      );
    end if;

    settled := settled + 1;
  end loop;

  return settled;
end;
$$;
revoke all on function public.settle_due_auctions() from public, anon;
grant execute on function public.settle_due_auctions() to authenticated;

-- ═══ 9. Account deletion ════════════════════════════════════════════════════
-- Clients cannot delete auth users (that needs the service role, which never
-- ships in the app). Deletes the caller's rows in FK-safe order, then the auth
-- user, which cascades the profile. Uploaded photos are removed by the app via
-- the Storage API first.
create function public.delete_account()
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
  delete from public.messages
    where sender_id = uid
       or conversation_id in (
         select id from public.conversations
         where buyer_id = uid or seller_id = uid
       );
  delete from public.conversations where buyer_id = uid or seller_id = uid;
  delete from public.listings where seller_id = uid;
  delete from auth.users where id = uid;
end;
$$;
revoke all on function public.delete_account() from public;
grant execute on function public.delete_account() to authenticated;

-- ═══ 10. Inbox ═══════════════════════════════════════════════════════════════
-- A small in-app message list. Rows are written ONLY by the two triggers
-- below (SECURITY DEFINER, so they bypass RLS); the app reads them when the
-- Inbox screen opens and may mark one read or delete it. Deliberately simple:
-- no realtime, no unread badge, no pop-up banner.
create table public.inbox (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references public.users (id) on delete cascade,
  kind        text not null check (kind in ('welcome', 'listing_match')),
  title       text not null,
  body        text not null,
  listing_id  uuid references public.listings (id) on delete cascade,
  route       text,
  read_at     timestamptz,
  created_at  timestamptz not null default now()
);

create index inbox_user_created_idx on public.inbox (user_id, created_at desc);
-- One message per user per car, so republishing a listing cannot spam anyone.
-- Partial, so the welcome row (null listing_id) never collides.
create unique index inbox_user_listing_idx
  on public.inbox (user_id, listing_id) where listing_id is not null;

alter table public.inbox enable row level security;

create policy "inbox_select_own" on public.inbox
  for select to authenticated using (user_id = auth.uid());
create policy "inbox_update_own" on public.inbox
  for update to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "inbox_delete_own" on public.inbox
  for delete to authenticated using (user_id = auth.uid());
-- No INSERT policy: only the triggers below write.

-- welcome: one message when the account is created.
create function public.notify_welcome()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.inbox (user_id, kind, title, body, route)
  values (
    new.id, 'welcome', 'Welcome to CarSell',
    'Set your car interests and we''ll tell you when a matching car is listed.',
    '/profile/interests'
  );
  return new;
end;
$$;

create trigger users_notify_welcome
  after insert on public.users
  for each row execute function public.notify_welcome();

-- listing_match: when a car goes on sale, tell every other user whose saved
-- interests it satisfies — the same rule the app uses for "Recommended for
-- you": every preference that is set must match. A user with no preferences
-- at all hears nothing.
create function public.notify_listing_match()
returns trigger
language plpgsql
security definer set search_path = public
as $$
declare
  u           record;
  makes       jsonb;
  bodies      jsonb;
  bmin        integer;
  bmax        integer;
  has_primary boolean;
  ok          boolean;
begin
  if new.status <> 'selling' then return new; end if;
  if tg_op = 'UPDATE' and old.status = 'selling' then return new; end if;

  for u in
    select id, interests from public.users where id <> new.seller_id
  loop
    makes  := coalesce(u.interests -> 'makes', '[]'::jsonb);
    bodies := coalesce(u.interests -> 'body_types', '[]'::jsonb);
    bmin   := (u.interests ->> 'budget_min_myr')::integer;
    bmax   := (u.interests ->> 'budget_max_myr')::integer;
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

    if ok then
      insert into public.inbox (user_id, kind, title, body, listing_id, route)
      values (
        u.id, 'listing_match', 'New car that matches your interests',
        new.year || ' ' || new.make || ' ' || new.model
          || ' · RM ' || to_char(new.price_myr, 'FM999,999,999')
          || ' · ' || new.state,
        new.id, '/listing/' || new.id
      )
      -- the arbiter index is partial, so its predicate must be repeated
      -- here or Postgres cannot match it (SQLSTATE 42P10).
      on conflict (user_id, listing_id) where listing_id is not null
      do nothing;
    end if;
  end loop;
  return new;
end;
$$;

create trigger listings_notify_match
  after insert or update of status on public.listings
  for each row execute function public.notify_listing_match();

-- ═══ 11. Market insights ════════════════════════════════════════════════════
-- One row ('latest') holding a precomputed snapshot of JPJ car registrations
-- (data.gov.my, CC BY 4.0), built offline by tool/build_car_popularity.dart
-- and published by 0002_seed.sql. Read-only for the app.
create table public.car_popularity (
  id                  text primary key,
  period_label        text        not null,
  generated_at        timestamptz not null,
  source_url          text        not null,
  total_registrations integer     not null,
  data                jsonb       not null
);

alter table public.car_popularity enable row level security;

create policy "car_popularity_select" on public.car_popularity
  for select to authenticated using (true);

-- ═══ 12. Realtime + storage ══════════════════════════════════════════════════
-- `add table` errors if the table is already in the publication, so each one
-- is guarded to keep this file re-runnable.
do $$
declare t text;
begin
  foreach t in array array['listings', 'conversations',
                           'messages', 'auctions', 'bids']
  loop
    if not exists (
      select 1 from pg_publication_tables
      where pubname = 'supabase_realtime'
        and schemaname = 'public'
        and tablename = t
    ) then
      execute format('alter publication supabase_realtime add table public.%I', t);
    end if;
  end loop;
end $$;

-- Private listing photos, served via signed URLs. Path: {user_id}/{listing_id}/{uuid}.jpg
insert into storage.buckets (id, name, public)
values ('listing-media', 'listing-media', false)
on conflict (id) do nothing;

create policy "listing_media_read" on storage.objects
  for select to authenticated using (bucket_id = 'listing-media');
create policy "listing_media_insert_own" on storage.objects
  for insert to authenticated with check (
    bucket_id = 'listing-media' and (storage.foldername(name))[1] = auth.uid()::text
  );
create policy "listing_media_update_own" on storage.objects
  for update to authenticated using (
    bucket_id = 'listing-media' and (storage.foldername(name))[1] = auth.uid()::text
  );
create policy "listing_media_delete_own" on storage.objects
  for delete to authenticated using (
    bucket_id = 'listing-media' and (storage.foldername(name))[1] = auth.uid()::text
  );

-- Public profile photos, so avatar_url can be a plain URL. Path: {user_id}/{uuid}.jpg
insert into storage.buckets (id, name, public)
values ('avatars', 'avatars', true)
on conflict (id) do nothing;

create policy "avatars_read" on storage.objects
  for select to authenticated using (bucket_id = 'avatars');
create policy "avatars_insert_own" on storage.objects
  for insert to authenticated with check (
    bucket_id = 'avatars' and (storage.foldername(name))[1] = auth.uid()::text
  );
create policy "avatars_update_own" on storage.objects
  for update to authenticated using (
    bucket_id = 'avatars' and (storage.foldername(name))[1] = auth.uid()::text
  );
create policy "avatars_delete_own" on storage.objects
  for delete to authenticated using (
    bucket_id = 'avatars' and (storage.foldername(name))[1] = auth.uid()::text
  );

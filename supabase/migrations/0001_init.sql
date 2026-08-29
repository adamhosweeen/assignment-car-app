-- v1 schema for the used-car marketplace (V1_SPEC §1), email+password auth.
-- Paste the whole file into the Supabase SQL editor and Run.
--
-- ⚠️  FULL RESET: the preamble below drops every app table, every account, and
-- every uploaded image, then rebuilds the final schema from scratch. Safe to
-- re-run any time on this dev project; never point it at real user data.

-- ─── Reset: drop everything first ────────────────────────────────────────────

-- App tables (policies and indexes go with them).
drop table if exists public.messages       cascade;
drop table if exists public.conversations  cascade;
drop table if exists public.listing_media  cascade;
drop table if exists public.listings       cascade;
drop table if exists public.profiles       cascade;

-- Signup trigger + helper functions.
drop trigger if exists on_auth_user_created on auth.users;
drop function if exists public.handle_new_user() cascade;
drop function if exists public.set_updated_at() cascade;

-- All auth accounts (cascades clean up anything still referencing them).
delete from auth.users;

-- Storage policies. NOTE: Supabase blocks SQL DELETE on storage.objects /
-- storage.buckets (storage.protect_delete) because the actual files live in
-- object storage, not the database. To also wipe the uploaded images, empty
-- the bucket in the dashboard: Storage → listing-media → select all → Delete.
-- Leftover files are harmless orphans otherwise — nothing references them
-- once listing_media is dropped.
drop policy if exists "listing_media_read"        on storage.objects;
drop policy if exists "listing_media_insert_own"  on storage.objects;
drop policy if exists "listing_media_update_own"  on storage.objects;
drop policy if exists "listing_media_delete_own"  on storage.objects;

-- ─── profiles ────────────────────────────────────────────────────────────────
create table public.profiles (
  id           uuid primary key references auth.users (id) on delete cascade,
  email        text,
  first_name   text,
  last_name    text,
  dob          date check (dob is null or dob <= (now() - interval '18 years')::date),
  phone        text,
  state        text,
  interests    jsonb not null default '{}'::jsonb,
  display_name text,
  avatar_url   text,
  created_at   timestamptz not null default now()
);

-- Mirror auth.users on signup. The registration payload rides in
-- raw_user_meta_data (signUp's `data`); this security-definer trigger is the
-- only thing that inserts into profiles — there is deliberately no INSERT
-- policy for clients.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles
    (id, email, phone, first_name, last_name, dob, state, interests, display_name)
  values (
    new.id,
    new.email,
    new.raw_user_meta_data->>'phone',
    new.raw_user_meta_data->>'first_name',
    new.raw_user_meta_data->>'last_name',
    nullif(new.raw_user_meta_data->>'dob', '')::date,
    new.raw_user_meta_data->>'state',
    coalesce(new.raw_user_meta_data->'interests', '{}'::jsonb),
    nullif(trim(coalesce(new.raw_user_meta_data->>'first_name', '') || ' ' ||
                coalesce(new.raw_user_meta_data->>'last_name', '')), '')
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ─── listings ────────────────────────────────────────────────────────────────
create table public.listings (
  id                   uuid primary key default gen_random_uuid(),
  seller_id            uuid not null references public.profiles (id),
  status               text not null default 'draft'
                         check (status in ('draft', 'active', 'sold', 'deleted')),
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
  registration_region  text not null check (registration_region in ('peninsular', 'sabah', 'sarawak')),
  state                text not null,
  city                 text not null,
  price_myr            int  not null check (price_myr > 0),
  negotiable           bool not null default true,
  description          text check (char_length(description) <= 1000),
  created_at           timestamptz not null default now(),
  updated_at           timestamptz not null default now()
);

create index listings_status_created_idx
  on public.listings (status, created_at desc);
create index listings_seller_status_idx
  on public.listings (seller_id, status);

create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger listings_set_updated_at
  before update on public.listings
  for each row execute function public.set_updated_at();

-- ─── listing_media ───────────────────────────────────────────────────────────
create table public.listing_media (
  id           uuid primary key default gen_random_uuid(),
  listing_id   uuid not null references public.listings (id) on delete cascade,
  storage_path text not null,
  media_type   text not null default 'photo' check (media_type in ('photo', 'video')),
  position     int  not null default 0,
  created_at   timestamptz not null default now()
);

create index listing_media_listing_idx
  on public.listing_media (listing_id, position);

-- ─── conversations / messages (schema only — no v1 UI, V1_SPEC §1) ────────────
create table public.conversations (
  id              uuid primary key default gen_random_uuid(),
  listing_id      uuid not null references public.listings (id) on delete cascade,
  buyer_id        uuid not null references public.profiles (id),
  seller_id       uuid not null references public.profiles (id),
  created_at      timestamptz not null default now(),
  last_message_at timestamptz,
  unique (listing_id, buyer_id)
);

create table public.messages (
  id               uuid primary key default gen_random_uuid(),
  conversation_id  uuid not null references public.conversations (id) on delete cascade,
  sender_id        uuid not null references public.profiles (id),
  body             text,
  message_type     text not null default 'text' check (message_type in ('text', 'offer')),
  offer_amount_myr int,
  created_at       timestamptz not null default now(),
  read_at          timestamptz
);

-- ─── Row Level Security ──────────────────────────────────────────────────────
alter table public.profiles       enable row level security;
alter table public.listings       enable row level security;
alter table public.listing_media  enable row level security;
alter table public.conversations  enable row level security;
alter table public.messages       enable row level security;

-- profiles: any authenticated user may read; a user updates only their own.
-- No INSERT policy — only the handle_new_user trigger inserts.
create policy "profiles_select" on public.profiles
  for select to authenticated using (true);
create policy "profiles_update_own" on public.profiles
  for update to authenticated using (id = auth.uid());

-- listings: active listings are public to authenticated users; a seller sees
-- and mutates only their own.
create policy "listings_select" on public.listings
  for select to authenticated
  using (status = 'active' or seller_id = auth.uid());
create policy "listings_insert_own" on public.listings
  for insert to authenticated with check (seller_id = auth.uid());
create policy "listings_update_own" on public.listings
  for update to authenticated using (seller_id = auth.uid());
create policy "listings_delete_own" on public.listings
  for delete to authenticated using (seller_id = auth.uid());

-- listing_media: mirror the parent listing's visibility / ownership.
create policy "listing_media_select" on public.listing_media
  for select to authenticated using (
    exists (
      select 1 from public.listings l
      where l.id = listing_id
        and (l.status = 'active' or l.seller_id = auth.uid())
    )
  );
create policy "listing_media_write_own" on public.listing_media
  for all to authenticated
  using (
    exists (select 1 from public.listings l where l.id = listing_id and l.seller_id = auth.uid())
  )
  with check (
    exists (select 1 from public.listings l where l.id = listing_id and l.seller_id = auth.uid())
  );

-- conversations / messages: participants only (buyer or seller).
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

-- ─── Account deletion ────────────────────────────────────────────────────────
-- Clients cannot delete auth users (that needs the service role, which never
-- ships in the app). This SECURITY DEFINER function deletes the calling
-- user's rows in FK-safe order, then the auth user itself (which cascades the
-- profile). Uploaded photos are removed by the app via the Storage API first.
create or replace function public.delete_account()
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
  delete from public.listings where seller_id = uid; -- cascades listing_media
  delete from auth.users where id = uid;             -- cascades profiles
end;
$$;

revoke all on function public.delete_account() from public;
grant execute on function public.delete_account() to authenticated;

-- ─── Realtime ────────────────────────────────────────────────────────────────
-- Push listing changes to connected clients (Buy feed + My Listings).
alter publication supabase_realtime add table public.listings;

-- ─── Storage: private listing-media bucket + policies ────────────────────────
insert into storage.buckets (id, name, public)
values ('listing-media', 'listing-media', false)
on conflict (id) do nothing;

-- Path convention: {user_id}/{listing_id}/{uuid}.jpg — a user writes only under
-- their own {user_id}/ prefix. Reads are open to authenticated users (images are
-- still served via signed URLs from the app).
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

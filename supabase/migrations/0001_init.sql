-- v1 schema for the used-car marketplace (V1_SPEC §1).
-- Paste into the Supabase SQL editor (or use the Supabase CLI). Idempotent-ish:
-- safe to run once on a fresh project.

-- ─── profiles ────────────────────────────────────────────────────────────────
create table if not exists public.profiles (
  id           uuid primary key references auth.users (id) on delete cascade,
  phone        text,
  display_name text,
  avatar_url   text,
  created_at   timestamptz not null default now()
);

-- Mirror auth.users on signup, defaulting display_name to a masked phone.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, phone, display_name)
  values (
    new.id,
    new.phone,
    'User ••' || right(coalesce(new.phone, ''), 4)
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ─── listings ────────────────────────────────────────────────────────────────
create table if not exists public.listings (
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

create index if not exists listings_status_created_idx
  on public.listings (status, created_at desc);
create index if not exists listings_seller_status_idx
  on public.listings (seller_id, status);

create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists listings_set_updated_at on public.listings;
create trigger listings_set_updated_at
  before update on public.listings
  for each row execute function public.set_updated_at();

-- ─── listing_media ───────────────────────────────────────────────────────────
create table if not exists public.listing_media (
  id           uuid primary key default gen_random_uuid(),
  listing_id   uuid not null references public.listings (id) on delete cascade,
  storage_path text not null,
  media_type   text not null default 'photo' check (media_type in ('photo', 'video')),
  position     int  not null default 0,
  created_at   timestamptz not null default now()
);

create index if not exists listing_media_listing_idx
  on public.listing_media (listing_id, position);

-- ─── conversations / messages (schema only — no v1 UI, V1_SPEC §1) ────────────
create table if not exists public.conversations (
  id              uuid primary key default gen_random_uuid(),
  listing_id      uuid not null references public.listings (id) on delete cascade,
  buyer_id        uuid not null references public.profiles (id),
  seller_id       uuid not null references public.profiles (id),
  created_at      timestamptz not null default now(),
  last_message_at timestamptz,
  unique (listing_id, buyer_id)
);

create table if not exists public.messages (
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

-- ─── 0003 · User reports + admin bans ────────────────────────────────────────
-- Adds user-to-user reporting and admin ban/unban (UserManagement module).
-- Apply AFTER 0002_admin_roles.sql (needs is_admin()).
--
-- * reports — a user reports another user with a title + description from the
--   seller page. Users can only insert their own reports; only admins read
--   them (via admin_reports()).
-- * admin_set_banned() — bans/unbans a user. The real login block is
--   auth.users.banned_until (GoTrue refuses new logins and token refreshes);
--   profiles.banned mirrors it so RLS and the admin UI can read it cheaply.
-- * Banned users' active listings disappear from everyone else's feed/search
--   (listings_select recreated) and they vanish from seller search
--   (public_profiles recreated with `where not banned`).
--
-- Paste this whole file into the Supabase SQL editor. Safe to re-run.

-- ─── Banned flag ─────────────────────────────────────────────────────────────
alter table public.profiles
  add column if not exists banned boolean not null default false;

-- ─── reports ─────────────────────────────────────────────────────────────────
create table if not exists public.reports (
  id           uuid primary key default gen_random_uuid(),
  reporter_id  uuid not null references public.profiles (id) on delete cascade,
  reported_id  uuid not null references public.profiles (id) on delete cascade,
  title        text not null check (char_length(trim(title)) between 1 and 80),
  description  text not null check (char_length(trim(description)) between 1 and 500),
  status       text not null default 'open' check (status in ('open', 'resolved')),
  created_at   timestamptz not null default now()
);
create index if not exists reports_status_created_idx
  on public.reports (status, created_at desc);

alter table public.reports enable row level security;

-- Users may only file reports as themselves, and not against themselves.
-- No select/update/delete policies: only admins read, via the RPC below.
drop policy if exists "reports_insert_own" on public.reports;
create policy "reports_insert_own" on public.reports
  for insert to authenticated
  with check (reporter_id = auth.uid() and reporter_id <> reported_id);

-- ─── admin_reports() ─────────────────────────────────────────────────────────
drop function if exists public.admin_reports();
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
    left join public.profiles pr on pr.id = r.reporter_id
    left join public.profiles pd on pd.id = r.reported_id
    order by r.created_at desc;
end;
$$;
revoke all on function public.admin_reports() from public, anon;
grant execute on function public.admin_reports() to authenticated;

-- ─── admin_resolve_report() ──────────────────────────────────────────────────
create or replace function public.admin_resolve_report(report_id uuid)
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

-- ─── admin_set_banned() ──────────────────────────────────────────────────────
-- banned_until = 'infinity' makes GoTrue refuse logins and token refreshes,
-- so the ban holds without the service-role key ever reaching the app.
create or replace function public.admin_set_banned(target uuid, ban boolean)
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
    select 1 from public.profiles where id = target and role = 'admin'
  ) then
    raise exception 'admins cannot be banned' using errcode = '42501';
  end if;
  update auth.users
    set banned_until = case when ban then 'infinity'::timestamptz end
    where id = target;
  update public.profiles set banned = ban where id = target;
end;
$$;
revoke all on function public.admin_set_banned(uuid, boolean) from public, anon;
grant execute on function public.admin_set_banned(uuid, boolean) to authenticated;

-- ─── Hide banned users' content ──────────────────────────────────────────────
-- Feed/search/recommendations: banned sellers' cars are invisible to others
-- (they still see their own).
drop policy if exists "listings_select" on public.listings;
create policy "listings_select" on public.listings
  for select to authenticated
  using (
    seller_id = auth.uid()
    or (
      status = 'active'
      and not exists (
        select 1 from public.profiles p
        where p.id = seller_id and p.banned
      )
    )
  );

-- Seller search / seller pages: banned users disappear (their page shows the
-- app's existing "account no longer exists" state).
create or replace view public.public_profiles as
  select id, display_name, avatar_url, state, created_at
  from public.profiles
  where not banned;
revoke all on public.public_profiles from anon, public;
grant select on public.public_profiles to authenticated;

-- ─── admin_user_stats(): now also returns banned ─────────────────────────────
drop function if exists public.admin_user_stats();
create function public.admin_user_stats()
returns table (
  id           uuid,
  display_name text,
  avatar_url   text,
  email        text,
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
      p.id, p.display_name, p.avatar_url, p.email, p.phone, p.dob, p.state,
      p.role, p.banned, p.created_at,
      count(l.id) filter (where l.status = 'active') as active_count,
      count(l.id) filter (where l.status = 'sold')   as sold_count
    from public.profiles p
    left join public.listings l on l.seller_id = p.id
    group by p.id
    order by p.created_at desc;
end;
$$;
revoke all on function public.admin_user_stats() from public, anon;
grant execute on function public.admin_user_stats() to authenticated;

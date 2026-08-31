-- ─── 0002 · Admin roles ──────────────────────────────────────────────────────
-- Adds role-based admin access (UserManagement module).
--
-- * profiles.role — 'user' (default) or 'admin'. Extensible: widen the check.
-- * protect_role trigger — users cannot change roles through the API; only an
--   existing admin, or SQL run from the dashboard (no auth.uid()), can.
-- * is_admin() — how the database asks "is the caller an admin?".
-- * admin_user_stats() — the admin screen's query: every user plus how many
--   cars they have listed (active) and sold. Refuses non-admin callers, so it
--   is safe to expose to the app despite bypassing profiles RLS.
--
-- Paste this whole file into the Supabase SQL editor (safe to re-run), then
-- seed your first admin — this works from the dashboard because it has no
-- auth.uid():
--
--   update public.profiles set role = 'admin' where email = 'you@example.com';

-- ─── Role column ─────────────────────────────────────────────────────────────
alter table public.profiles
  add column if not exists role text not null default 'user'
    check (role in ('user', 'admin'));

-- ─── is_admin() ──────────────────────────────────────────────────────────────
create or replace function public.is_admin()
returns boolean
language sql stable
security definer set search_path = public
as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid() and role = 'admin'
  );
$$;
revoke all on function public.is_admin() from public, anon;
grant execute on function public.is_admin() to authenticated;

-- ─── Block self-promotion ────────────────────────────────────────────────────
-- profiles_update_own lets a user update their whole row, so without this a
-- user could set their own role. auth.uid() is null for dashboard/service-role
-- sessions — those may always change roles (that's how the first admin is
-- seeded).
create or replace function public.protect_role()
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

drop trigger if exists profiles_protect_role on public.profiles;
create trigger profiles_protect_role
  before update on public.profiles
  for each row execute function public.protect_role();

-- ─── admin_user_stats() ──────────────────────────────────────────────────────
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
      p.role, p.created_at,
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

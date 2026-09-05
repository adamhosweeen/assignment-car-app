-- ═══ 0016 · admin_user_stats also returns the name columns (module: admin) ═══
-- The app no longer keeps a separate admin-only model of a user: the admin
-- screen now composes the ordinary `Profile` with the two listing counts. That
-- needs `first_name` and `last_name` in the RPC's row so `Profile` can decode
-- it like any other profiles row. `display_name` stays for compatibility.
--
-- The return type changes, so the function is dropped and recreated (as 0003
-- did). Body is otherwise identical to 0013's.
--
-- Depends on: 0002 (is_admin), 0003 (banned), 0013 (the four statuses).
-- Re-runnable.

drop function if exists public.admin_user_stats();
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
    from public.profiles p
    left join public.listings l on l.seller_id = p.id
    group by p.id
    order by p.created_at desc;
end;
$$;
revoke all on function public.admin_user_stats() from public, anon;
grant execute on function public.admin_user_stats() to authenticated;

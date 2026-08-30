-- ═══ 60 · notifications (module: notifications) ═════════════════════════════════
-- In-app inbox. Rows are created ONLY by the trigger functions below
-- (SECURITY DEFINER, so they bypass RLS); clients read, mark read, and delete
-- their own rows. Kinds: welcome (on signup), listing_match (a newly published
-- listing fits the user's saved interests), insights_updated (car_popularity
-- refreshed). Depends on: 10, 20, 50. Additive: safe to paste on its own.
--
-- Other modules that want to notify (e.g. Bid): add your kind to the check
-- constraint below AND to `NotificationKind` in
-- lib/model/notifications/app_notification.dart, then insert from your own
-- SECURITY DEFINER trigger in your module file.
create table if not exists public.notifications (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references public.profiles (id) on delete cascade,
  kind        text not null check (kind in ('welcome', 'listing_match', 'insights_updated')),
  title       text not null,
  body        text not null,
  listing_id  uuid references public.listings (id) on delete cascade,
  route       text,
  read_at     timestamptz,
  created_at  timestamptz not null default now()
);
create index if not exists notifications_user_created_idx
  on public.notifications (user_id, created_at desc);

alter table public.notifications enable row level security;
drop policy if exists "notifications_select_own" on public.notifications;
drop policy if exists "notifications_update_own" on public.notifications;
drop policy if exists "notifications_delete_own" on public.notifications;
create policy "notifications_select_own" on public.notifications
  for select to authenticated using (user_id = auth.uid());
create policy "notifications_update_own" on public.notifications
  for update to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "notifications_delete_own" on public.notifications
  for delete to authenticated using (user_id = auth.uid());
-- No INSERT policy: only the triggers below write.

-- welcome: one row when the profile is created (i.e. on signup).
create or replace function public.notify_welcome()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.notifications (user_id, kind, title, body, route)
  values (
    new.id, 'welcome', 'Welcome to Garaj',
    'Set your car interests and we''ll tell you when a matching car is listed.',
    '/profile/interests'
  );
  return new;
end;
$$;
drop trigger if exists profiles_notify_welcome on public.profiles;
create trigger profiles_notify_welcome
  after insert on public.profiles
  for each row execute function public.notify_welcome();

-- listing_match: when a listing becomes active, notify every other user whose
-- saved interests it satisfies — the same rule as the app's "Recommended for
-- you" row: every set preference (brands, body types, budget) must match;
-- users with none of those fall back to same state. Never twice for the
-- same user + listing (an edit re-publishes through draft → active).
create or replace function public.notify_listing_match()
returns trigger
language plpgsql
security definer set search_path = public
as $$
declare
  p           record;
  makes       jsonb;
  bodies      jsonb;
  bmin        integer;
  bmax        integer;
  has_primary boolean;
  ok          boolean;
begin
  if new.status <> 'active' then return new; end if;
  if tg_op = 'UPDATE' and old.status = 'active' then return new; end if;

  for p in
    select id, state, interests from public.profiles where id <> new.seller_id
  loop
    makes  := coalesce(p.interests -> 'makes', '[]'::jsonb);
    bodies := coalesce(p.interests -> 'body_types', '[]'::jsonb);
    bmin   := (p.interests ->> 'budget_min_myr')::integer;
    bmax   := (p.interests ->> 'budget_max_myr')::integer;
    has_primary := jsonb_array_length(makes) > 0
                or jsonb_array_length(bodies) > 0
                or bmin is not null or bmax is not null;

    if has_primary then
      ok := (jsonb_array_length(makes) = 0 or makes ? new.make)
        and (jsonb_array_length(bodies) = 0 or bodies ? new.body_type)
        and (bmin is null or new.price_myr >= bmin)
        and (bmax is null or new.price_myr <= bmax);
    else
      ok := p.state is not null and p.state = new.state;
    end if;

    if ok and not exists (
      select 1 from public.notifications n
      where n.user_id = p.id and n.listing_id = new.id
    ) then
      insert into public.notifications (user_id, kind, title, body, listing_id, route)
      values (
        p.id, 'listing_match', 'New car that matches your interests',
        new.year || ' ' || new.make || ' ' || new.model
          || ' · RM ' || to_char(new.price_myr, 'FM999,999,999')
          || ' · ' || new.state,
        new.id, '/listing/' || new.id
      );
    end if;
  end loop;
  return new;
end;
$$;
drop trigger if exists listings_notify_match on public.listings;
create trigger listings_notify_match
  after insert or update of status on public.listings
  for each row execute function public.notify_listing_match();

-- insights_updated: everyone hears when the market snapshot is refreshed.
create or replace function public.notify_insights_updated()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.notifications (user_id, kind, title, body, route)
  select id, 'insights_updated', 'Market insights updated',
         'Fresh JPJ registration data for ' || new.period_label || ' is in.',
         '/profile/insights'
  from public.profiles;
  return new;
end;
$$;
drop trigger if exists car_popularity_notify on public.car_popularity;
create trigger car_popularity_notify
  after insert or update on public.car_popularity
  for each row execute function public.notify_insights_updated();

-- Realtime: push inbox changes (the app filters by user_id). Guarded.
do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'notifications'
  ) then
    alter publication supabase_realtime add table public.notifications;
  end if;
end $$;

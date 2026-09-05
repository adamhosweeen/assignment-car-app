-- ═══ 0010 · listing_match needs real interests (module: notifications) ═══════
-- 0001 gave `notify_listing_match()` a fallback: a user who had set no car
-- preferences at all was notified about every new listing in their own state.
-- The same fallback existed client-side in `rankRecommended`, so the Buy tab's
-- "Recommended for you" row filled up with same-state cars too.
--
-- That contradicts the rule in CLAUDE.md §2 — "a listing must satisfy every car
-- preference the user set (brands, body types, budget); location/fuel/
-- transmission only order the matches" — and it surprises users: set nothing,
-- still get an inbox full of matches. Location now only *orders* matches, and a
-- user with no preferences gets no listing_match notifications at all.
--
-- Depends on: 0001 (listings, profiles, notifications, the trigger this
-- replaces).
-- Additive: safe to paste on its own; re-runnable.
--
-- Paired with the client change in lib/control/listings/recommendations_provider.dart.

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

    -- No saved preferences means nothing to match against: stay quiet rather
    -- than fall back to "anything in your state".
    if not has_primary then
      continue;
    end if;

    ok := (jsonb_array_length(makes) = 0 or makes ? new.make)
      and (jsonb_array_length(bodies) = 0 or bodies ? new.body_type)
      and (bmin is null or new.price_myr >= bmin)
      and (bmax is null or new.price_myr <= bmax);

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

-- Clear the rows the old fallback already wrote: listing_match notifications
-- belonging to users who never set a car preference. Drop this statement if you
-- would rather keep the existing inboxes as they are.
delete from public.notifications n
using public.profiles p
where n.user_id = p.id
  and n.kind = 'listing_match'
  and coalesce(jsonb_array_length(coalesce(p.interests -> 'makes', '[]'::jsonb)), 0) = 0
  and coalesce(jsonb_array_length(coalesce(p.interests -> 'body_types', '[]'::jsonb)), 0) = 0
  and (p.interests ->> 'budget_min_myr') is null
  and (p.interests ->> 'budget_max_myr') is null;

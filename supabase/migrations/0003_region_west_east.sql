-- ═══ 0003 · region West / East (module: sell) ════════════════════════════════
-- `registration_region` was {peninsular, sabah, sarawak}. The sell form now
-- offers just West / East Malaysia and filters the state list by it, so this
-- collapses the values and swaps the CHECK constraint.
--   peninsular -> west
--   sabah, sarawak -> east
-- Depends on: 0001. Additive and re-runnable.

alter table public.listings
  drop constraint if exists listings_registration_region_check;

update public.listings set registration_region = case registration_region
  when 'peninsular' then 'west'
  when 'sabah'      then 'east'
  when 'sarawak'    then 'east'
  else registration_region
end
where registration_region in ('peninsular', 'sabah', 'sarawak');

alter table public.listings
  add constraint listings_registration_region_check
  check (registration_region in ('west', 'east'));

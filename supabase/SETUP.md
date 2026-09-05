# Supabase setup (build-order Step 2)

This wires the backend. Supabase is **required** — without the keys the app
shows a configuration-error screen at launch (there is no offline fake
backend).

## 1. Create the project
- New project in region **`ap-southeast-1` (Singapore)** — lowest latency to Malaysia.
- Note the **Project URL** and the **anon public** key (Settings → API).
  The **service_role** key must never go into the app.

## 2. Apply the schema

Two files, pasted in order into the SQL editor. Both are safe to re-run.

### 2a. Schema (`migrations/0001_schema.sql`)
- SQL Editor → paste all of [`migrations/0001_schema.sql`](migrations/0001_schema.sql) → Run.
- ⚠️ This is a **full reset**: it drops every app table and every auth account,
  then rebuilds the whole schema — tables, RLS, functions, triggers, realtime
  and storage buckets. Only ever run it on a dev project.
- Uploaded images can't be deleted from SQL. To wipe them too: Storage →
  `listing-media` → select all → Delete, and the same for `avatars`.

### 2b. Seed (`migrations/0002_seed.sql`)
- SQL Editor → paste [`migrations/0002_seed.sql`](migrations/0002_seed.sql) → Run.
- Publishes the market-insights snapshot (`car_popularity`). Every signed-up
  user gets an "insights updated" notification when this runs.
- To refresh the data: `dart run tool/build_car_popularity.dart` (downloads
  ~12 monthly CSVs from data.gov.my into `build/data_gov_my/`, aggregates,
  and rewrites `0002_seed.sql`), then re-paste.

### 2c. Seed your first admin
The app's Admin screen is gated on `profiles.role = 'admin'`, which users can't
set themselves. Seed it once from the SQL editor after signing up in the app:

```sql
update public.profiles set role = 'admin' where email = 'you@example.com';
```

### 2d. Optional: punctual auction settlement
Auctions settle when any user next opens the Bid tab (the app calls
`settle_due_auctions()` before each read). To close them on time with no
traffic, enable the **pg_cron** extension (Database → Extensions) and run:

```sql
select cron.schedule('settle-auctions', '* * * * *',
                     $$select public.settle_due_auctions()$$);
```

### Acceptance check
1. `select status, count(*) from public.listings group by 1;` → only
   `selling`, `bidding`, `hidden`, `sold`.
2. Seller A: Bid tab → **Start an auction** → pick a car → 1 hour → confirm.
   The car shows **Bidding** in My Listings and the Buy feed; Buy now becomes
   "Go to the auction".
3. Buyer B: bid below the minimum → refused with the required amount; bid the
   starting price → accepted; raise it → accepted.
4. Seller A cannot mark the car sold or delete it while bidding runs.
5. Expire it: `update public.auctions set ends_at = now() where id = '<id>';`
   then reopen the Bid tab. The car is **Sold** at the winning amount, a
   `purchases` row exists for B with `method = 'bid'`, and the won / outbid /
   ended notifications arrive.
6. `delete from public.listings where id = '<sold id>';` as the seller → 0 rows.

## 3. Enable email + password auth
- Authentication → Sign In / Providers → **Email** → enable.
- **Disable "Confirm email"** for v1 — the app expects `signUp` to return a live
  session; with confirmation on, new users are told to check their inbox and the
  flow stalls.
- Optional: set minimum password length to 8 to match the client-side rule.
- There is no in-app password reset (out of scope). If a user forgets their
  password, reset it from the dashboard: Authentication → Users → the user →
  send recovery / update password.
- **Account deletion** is the `delete_account()` function in
  `0001_schema.sql`; nothing extra to enable.

## 4. Hand the keys back
Give me the **Project URL** and **anon key**. They're injected at build time via
`--dart-define` (never committed):

```
flutter run --dart-define-from-file=env.json
```

You don't have to type that: the Android Studio run configuration
(`.idea/runConfigurations/main_dart.xml`) and the VS Code launch config
(`.vscode/launch.json`) already pass `--dart-define-from-file=env.json`, so the
IDE **Run ▶** button is enough. `env.json` itself stays gitignored.

There is no code-generation step — models are plain Dart with hand-written
`fromJson`/`toJson`, so a fresh clone runs as-is.

## 5. Then I do (Step 2 app side)
- Add `supabase_flutter`, initialise the client from the `--dart-define` values.
- Implement `SupabaseListingsRepository` / `SupabaseAuthRepository` against the
  same domain interfaces and switch the providers in `lib/app/providers.dart`.
- Wire realtime subscriptions, signed-URL image loading, and on-device media
  upload with per-file progress + retry.

## Acceptance to re-verify afterwards (V1_SPEC §5)
Two devices / two accounts: publish appears in the other user's Buy feed and on a
second device within ~2 s without refresh; a user cannot edit/delete another
user's listing (verify by calling the API directly, not just the hidden button).

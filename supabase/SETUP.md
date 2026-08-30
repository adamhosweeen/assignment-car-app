# Supabase setup (build-order Step 2)

This wires the backend. Supabase is **required** — without the keys the app
shows a configuration-error screen at launch (there is no offline fake
backend).

## 1. Create the project
- New project in region **`ap-southeast-1` (Singapore)** — lowest latency to Malaysia.
- Note the **Project URL** and the **anon public** key (Settings → API).
  The **service_role** key must never go into the app.

## 2. Apply the schema
- SQL Editor → paste all of [`migrations/0001_init.sql`](migrations/0001_init.sql) → Run.
- ⚠️ The script **resets everything first** — it drops all app tables and deletes
  all auth accounts before rebuilding. Safe to re-run any time on this dev
  project; never use on real data.
- Supabase blocks SQL deletes on storage, so old uploaded images are not wiped by
  the script. To clear them too: Storage → `listing-media` → select all → Delete.
  (Leftovers are harmless orphans — nothing references them after the reset.)
- Creates: `profiles` (email auth fields, 18+ DOB check, interests jsonb),
  `listings`, `listing_media`, `conversations`/`messages` (schema only),
  `car_popularity` (market-insights snapshot, read-only), RLS on every table,
  the signup + `updated_at` triggers, realtime on `listings`, and the private
  `listing-media` storage bucket + policies.

### 2b. Seed market insights
- SQL Editor → paste [`seed/car_popularity.sql`](seed/car_popularity.sql) → Run.
  Without it, Profile → Market insights shows "not published yet" (no error).
- The seed is a snapshot of JPJ car registrations from
  [data.gov.my](https://data.gov.my/data-catalogue/registration_transactions_car)
  (CC BY 4.0). That dataset has no API — it is a bulk CSV — so the app never
  calls data.gov.my; only this seed does.
- **To refresh** (the source updates monthly): on your machine run
  `dart run tool/build_car_popularity.dart` (downloads ~80 MB once, cached in
  `build/data_gov_my/`), then paste the regenerated `seed/car_popularity.sql`.
  It is an upsert, so re-running it just replaces the row — no app release.
- If your schema is already applied and you don't want a full reset, paste just
  the "Market insights" block from `0001_init.sql` first — it's additive.

## 3. Enable email + password auth
- Authentication → Sign In / Providers → **Email** → enable.
- **Disable "Confirm email"** for v1 — the app expects `signUp` to return a live
  session; with confirmation on, new users are told to check their inbox and the
  flow stalls.
- Optional: set minimum password length to 8 to match the client-side rule.
- There is no in-app password reset (out of scope). If a user forgets their
  password, reset it from the dashboard: Authentication → Users → the user →
  send recovery / update password.
- **Account deletion:** the `delete_account()` function is part of
  `0001_init.sql`. If your schema is already applied and you don't want a full
  reset, paste just the "Account deletion" block from that file into the SQL
  editor and run it alone — it's additive (`create or replace`).

## 4. Hand the keys back
Give me the **Project URL** and **anon key**. They're injected at build time via
`--dart-define` (never committed):

```
flutter run --dart-define=SUPABASE_URL=<url> --dart-define=SUPABASE_ANON_KEY=<anon>
```

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

# Supabase setup (build-order Step 2)

This wires the backend. Supabase is **required** — without the keys the app
shows a configuration-error screen at launch (there is no offline fake
backend).

## 1. Create the project
- New project in region **`ap-southeast-1` (Singapore)** — lowest latency to Malaysia.
- Note the **Project URL** and the **anon public** key (Settings → API).
  The **service_role** key must never go into the app.

## 2. Apply the schema
- **Rule (CONTRIBUTING.md §3.4):** `0001_init.sql` is the frozen v1 baseline.
  Every later database change is a **new** file `migrations/000N_<module>_<desc>.sql`
  — never an edit to 0001. Apply files in numeric order; each one is paste-alone
  safe and re-runnable. Steps 2b–2d below describe blocks that shipped inside
  0001 before this rule; anything new gets its own step here naming its file.
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
  the signup + `updated_at` triggers, realtime on `listings`, the private
  `listing-media` storage bucket + policies, and the **public `avatars`**
  bucket + policies (profile photos; the app stores the public URL in
  `profiles.avatar_url`). Already applied? Paste just the "Storage: public
  avatars bucket" block — it's additive.

### 2c. Public profiles (seller search / seller pages)
- Part of `0001_init.sql`. On an already-applied schema, paste just the
  "Public profiles" block: it tightens `profiles` so each user can read only
  their **own** row (email, phone, DOB stay private) and creates the
  `public_profiles` view (id, display_name, avatar_url, state, created_at)
  that seller search and seller pages read. Without it, Find Sellers and the
  seller row on a listing show an error.

### 2d. Notifications (Profile → Inbox)
- Part of `0001_init.sql`. On an already-applied schema, paste just the
  "Notifications" block (after the market-insights table exists) — it creates
  the `notifications` table, its RLS, and the three trigger functions
  (welcome on signup, listing matches your interests, market insights
  refreshed), and adds the table to the realtime publication:
  `alter publication supabase_realtime add table public.notifications;`
- Nothing in the app inserts notifications; only these triggers do. The
  welcome row appears for accounts created **after** the trigger exists.

### 2f. Chat realtime + read receipts
- SQL Editor → paste [`migrations/0002_chat_realtime.sql`](migrations/0002_chat_realtime.sql) → Run.
- Paste-alone safe and re-runnable — adds `conversations`/`messages` to the
  realtime publication, a couple of indexes, and the
  `mark_conversation_read()` function (participants only; lets a user mark the
  *other* person's messages read, which the frozen `messages_participants`
  policy in `0001_init.sql` can't do via a plain client-side update). Without
  it, Chat has no realtime updates and unread dots never clear.

### 2g. Chat listing visibility
- SQL Editor → paste [`migrations/0003_chat_listing_visibility.sql`](migrations/0003_chat_listing_visibility.sql) → Run.
- Paste-alone safe and re-runnable — adds a second `listings`/`listing_media`
  SELECT policy so a conversation's buyer and seller can still see the listing
  (status, photos, everything) after it's marked sold or deleted, instead of
  the row vanishing behind the frozen `status = 'active' or seller_id =
  auth.uid()` policy in `0001_init.sql`. Without it, tapping the listing name
  in a chat thread for a car that's since been marked sold shows "This listing
  is no longer available." instead of the real "Sold" state.

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
flutter run --dart-define-from-file=env.json
```

You don't have to type that: the Android Studio run configuration
(`.idea/runConfigurations/main_dart.xml`) and the VS Code launch config
(`.vscode/launch.json`) already pass `--dart-define-from-file=env.json`, so the
IDE **Run ▶** button is enough. `env.json` itself stays gitignored.

Code generation (`*.g.dart`, `*.freezed.dart`) is only needed after a fresh clone
or when a `@freezed` / `@riverpod` file changes. Instead of re-running the build
by hand, keep a watcher open in a terminal while developing:

```
dart run build_runner watch --delete-conflicting-outputs
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

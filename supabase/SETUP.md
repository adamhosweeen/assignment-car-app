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

### 2e. Admin roles (`migrations/0002_admin_roles.sql`)
- SQL Editor → paste all of
  [`migrations/0002_admin_roles.sql`](migrations/0002_admin_roles.sql) → Run.
  Additive and safe to re-run; apply **after** 0001.
- Adds `profiles.role` (`'user'` default / `'admin'`), a trigger that blocks
  role changes through the API (only an existing admin — or SQL run here in
  the dashboard — can change one), and the `admin_user_stats()` function the
  in-app admin screen calls. The function refuses non-admin callers.
- Seed your first admin (dashboard SQL, one line — replace the email):
  ```sql
  update public.profiles set role = 'admin' where email = 'you@example.com';
  ```
- In the app, that account then shows an **Admin** row on the Profile tab
  (log out/in, or pull-to-refresh Profile, to pick up the new role).

### 2f. Reports & bans (`migrations/0003_reports_bans.sql`)
- SQL Editor → paste all of
  [`migrations/0003_reports_bans.sql`](migrations/0003_reports_bans.sql) → Run.
  Additive and safe to re-run; apply **after** 0002 (it uses `is_admin()`).
- Adds the `reports` table (users report a seller with a title + description;
  insert-own RLS, admins read via `admin_reports()`), `admin_resolve_report()`,
  and `admin_set_banned()` — banning sets `auth.users.banned_until` so the
  user cannot log in or refresh their session, and flips `profiles.banned`,
  which hides their active listings from buyers and removes them from seller
  search. Unbanning reverses all of it.
- Also recreates `admin_user_stats()` to include the `banned` column, so run
  this after 0002 even on a fresh project.

### 2g. Buy checkout (dummy) (`migrations/0004_buy_listing.sql`)
- SQL Editor → paste [`migrations/0004_buy_listing.sql`](migrations/0004_buy_listing.sql) → Run.
  Additive and re-runnable (`create or replace`); apply **after** 0001.
- Creates the `buy_listing(uuid)` SECURITY DEFINER function. The Buy button on a
  listing calls it to flip an `active` listing to `sold`. Without it the
  purchase appears to succeed but the RLS `listings_update_own` policy blocks a
  non-seller's update, so the car stays in the Buy feed.

### 2h. Region West / East (`migrations/0005_region_west_east.sql`)
- SQL Editor → paste [`migrations/0005_region_west_east.sql`](migrations/0005_region_west_east.sql) → Run.
  Additive and re-runnable; apply **after** 0001.
- Collapses `listings.registration_region` from `{peninsular, sabah, sarawak}`
  to `{west, east}` (maps existing rows) and swaps the CHECK constraint. The
  sell form now picks a region first and filters the state list by it. Run
  this before selling with an app build that includes the change, or publish
  fails the constraint.

### 2i. Chat realtime + read receipts (`migrations/0006_chat_realtime.sql`)
- SQL Editor → paste [`migrations/0006_chat_realtime.sql`](migrations/0006_chat_realtime.sql) → Run.
- Paste-alone safe and re-runnable — adds `conversations`/`messages` to the
  realtime publication, a couple of indexes, and the
  `mark_conversation_read()` function (participants only; lets a user mark the
  *other* person's messages read, which the frozen `messages_participants`
  policy in `0001_init.sql` can't do via a plain client-side update). Without
  it, Chat has no realtime updates and unread dots never clear.

### 2j. Chat listing visibility (`migrations/0007_chat_listing_visibility.sql`)
- SQL Editor → paste [`migrations/0007_chat_listing_visibility.sql`](migrations/0007_chat_listing_visibility.sql) → Run.
- Paste-alone safe and re-runnable — adds a second `listings`/`listing_media`
  SELECT policy so a conversation's buyer and seller can still see the listing
  (status, photos, everything) after it's marked sold or deleted, instead of
  the row vanishing behind the frozen `status = 'active' or seller_id =
  auth.uid()` policy in `0001_init.sql`. Without it, tapping the listing name
  in a chat thread for a car that's since been marked sold shows "This listing
  is no longer available." instead of the real "Sold" state.

### 2k. Chat offer confirm + buy (`migrations/0008_chat_offer_confirm.sql`)
- SQL Editor → paste [`migrations/0008_chat_offer_confirm.sql`](migrations/0008_chat_offer_confirm.sql) → Run.
- Additive and re-runnable; apply **after** 0001 and 0004 (mirrors `buy_listing`'s
  "flip an active listing to sold" pattern, but at the offer's price).
- Adds `messages.offer_confirmed_at` plus two SECURITY DEFINER functions:
  `confirm_offer()` (the recipient of a buyer's offer — the seller — accepts
  its price; the frozen `messages_participants` policy in `0001_init.sql`
  only lets the *sender* update a message via a plain client-side update, the
  wrong direction here) and `buy_at_offer()` (the buyer completes the sale at
  the offer's price — confirming it first in the same call if the seller sent
  it, otherwise it must already be confirmed). Without this, the "Make an
  offer" buttons in chat have nothing to call.

### 2l. Bids (`migrations/0009_bids.sql`)
- SQL Editor → paste [`migrations/0009_bids.sql`](migrations/0009_bids.sql) → Run.
- Additive and re-runnable; apply **after** 0001 (needs `listings`, `profiles`,
  `notifications`) and conceptually after 0004, whose "flip an active listing to
  sold" pattern `respond_to_bid()` mirrors — at the accepted bid's amount rather
  than the list price.
- Creates the `bids` table (amount in integer MYR, status
  pending/accepted/rejected/withdrawn, the bidder's contact number and WhatsApp
  opt-in) with **SELECT and INSERT policies only**: a bidder sees their own
  bids, a seller sees every bid on their own cars, and nobody sees anybody
  else's amounts. A partial unique index allows one *pending* bid per person
  per car.
- Every status change goes through a SECURITY DEFINER function, because RLS
  can't express "the seller may set accepted/rejected and nothing else":
  `withdraw_bid()` (bidder pulls back a pending bid) and `respond_to_bid()`
  (seller accepts — which also rejects the other pending bids and sells the car
  at that amount — or rejects). A trigger on `listings` rejects pending bids
  whenever a car leaves the market some other way, so no bid is stranded as
  "pending" forever.
- **Changes an existing object:** it drops and re-adds
  `notifications_kind_check` to allow three new kinds (`bid_placed`,
  `bid_accepted`, `bid_rejected`) and adds two triggers that write them. Per
  CONTRIBUTING §3.4 rule 4 that belongs in this new file, not an edit to 0001.
  The `NotificationKind` enum in the app is extended to match.
- Adds `bids` to the realtime publication (guarded, so re-running won't error).
- Without this, the Bid tab and the "Place a bid" button on Listing Detail have
  no table to read or write.

### 2m. Matches need real interests (`migrations/0010_match_interests_only.sql`)
- SQL Editor → paste
  [`migrations/0010_match_interests_only.sql`](migrations/0010_match_interests_only.sql)
  → Run.
- Additive and re-runnable; apply **after** 0001 (replaces the
  `notify_listing_match()` trigger it created).
- 0001 notified a user with **no** saved car preferences about every new listing
  in their own state. That contradicts CLAUDE.md §2 ("location/fuel/transmission
  only order the matches") and fills a brand-new user's inbox with cars they
  never asked about. After this, a user with no preferences gets no
  `listing_match` notifications at all; location still only orders real matches.
- Ends with a `delete` that clears the `listing_match` rows the old fallback
  already wrote for preference-less users. Drop that statement if you would
  rather leave existing inboxes untouched.
- Pairs with the client change in
  `lib/control/listings/recommendations_provider.dart` — the Buy tab's
  "Recommended for you" row used the same fallback and now shows its empty
  state ("Set your car interests…") instead.

### 2n. Banned sellers' cars really disappear (`migrations/0011_hide_banned_listings.sql`)
- SQL Editor → paste
  [`migrations/0011_hide_banned_listings.sql`](migrations/0011_hide_banned_listings.sql)
  → Run.
- Additive and re-runnable; apply **after** 0003 (needs `profiles.banned`).
- **Fixes a real hole.** 0003's ban check lived in a subquery inside the
  `listings_select` policy, but RLS applies to tables referenced inside a
  policy expression — and `profiles` is own-row only, so the subquery always
  matched zero rows and every banned seller's cars stayed visible. The flag is
  now read through the SECURITY DEFINER `is_banned()`, the same pattern
  `is_admin()` uses.
- Verify after banning someone, as a *different* signed-in user:
  `select count(*) from public.listings where seller_id = '<banned uuid>';`
  should return 0.

### 2o. Purchase history (`migrations/0012_purchases.sql`)
- SQL Editor → paste [`migrations/0012_purchases.sql`](migrations/0012_purchases.sql)
  → Run.
- Additive and re-runnable; apply **after** 0004, 0008 and 0009 — it replaces
  `buy_listing()`, `buy_at_offer()` and `respond_to_bid()` so every route that
  sells a car also writes the receipt.
- Creates `purchases` (buyer, seller, listing, price actually paid, method,
  and a make/model/year snapshot) with a **select-own policy and no write
  policy** — only the SECURITY DEFINER functions insert, and neither side can
  rewrite a receipt. `listing_id` is `on delete set null`, so the history
  survives the listing being removed with the snapshot standing in.
- Also adds `listings_select_buyer` / `listing_media_select_buyer`: a buyer
  keeps read access to the car they bought, which `listings_select` would
  otherwise deny once it is sold.
- **No backfill.** Sales made before this migration genuinely have no buyer
  recorded, so history starts from here.

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

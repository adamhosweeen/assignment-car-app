# Supabase setup (build-order Step 2)

This wires the backend. Supabase is **required** — without the keys the app
shows a configuration-error screen at launch (there is no offline fake
backend).

## 1. Create the project
- New project in region **`ap-southeast-1` (Singapore)** — lowest latency to Malaysia.
- Note the **Project URL** and the **anon public** key (Settings → API).
  The **service_role** key must never go into the app.

## 2. Apply the schema

Pasted into the SQL editor. All of these are safe to re-run.

### 2a. Schema (`migrations/0001_schema.sql`)
- SQL Editor → paste all of [`migrations/0001_schema.sql`](migrations/0001_schema.sql) → Run.
- ⚠️ This is a **full reset**: it drops every app table and every auth account,
  then rebuilds the whole schema — tables, RLS, functions, triggers, realtime
  and storage buckets. Only ever run it on a dev project.
- Uploaded images can't be deleted from SQL. To wipe them too: Storage →
  `listing-media` → select all → Delete, and the same for `avatars`.

### 2a-bis. Incremental patches (`migrations/0002_*.sql` onwards)

Anything numbered above `0001` is a **patch**: it only adds or replaces
functions, so it keeps every row and every account. Run these on a project that
already has data instead of re-running `0001`.

- `0002_extend_auction.sql` — adds `extend_auction(uuid, timestamptz)`, the RPC
  behind **Extend auction** on the auction screen. Without it that button
  fails with *"This feature is not available on the server yet."* (PostgREST
  answers `PGRST202` — the function is not in its schema cache.)
- `0002_chat_recall_and_hide.sql` — adds `recall_message(uuid)` (withdraw your
  own chat message within 2 minutes), `hide_conversation(uuid)` (swipe a
  thread away from your own Chat tab), and a trigger that keeps
  `last_message_at` on the server's clock so a hidden thread reliably
  reappears once a later message arrives. Without it, recall/hide fail the
  same way as above. If you already ran an earlier copy of this file (before
  the trigger existed), re-run it — it's still safe to re-run.
- `0003_chat_images.sql` — adds `message_type = 'image'`, `messages.image_path`,
  and a private `chat-media` storage bucket (scoped to the two people in the
  conversation) for the "send a photo" button in a chat thread. Without it,
  picking a photo fails to upload (storage bucket not found / RLS denies it).
- `0004_chat_sold_message.sql` — adds `message_type = 'sold'` and updates
  `buy_at_offer` to post a "Car sold at RM X" message into the conversation
  once a chat-offer purchase completes.

A fresh project that has just run `0001` already contains all of them; running
the patches anyway changes nothing.

### 2b. Market insights function (`functions/market-insights/index.ts`)

`car_popularity` starts **empty** — there is no seed file. The Edge Function is
the only thing that fills it, so until you do this, Market Insights shows
"not published yet" while the rest of the app works normally.

1. Dashboard → **Edge Functions** → **New function**, name it exactly
   `market-insights`, paste
   [`functions/market-insights/index.ts`](functions/market-insights/index.ts),
   Deploy.
2. **Invoke it once** to populate the table:
   ```
   curl -X POST https://<project-ref>.supabase.co/functions/v1/market-insights      -H "Authorization: Bearer <your-anon-key>"
   ```
   It replies with the row count, elapsed ms and the top 10 makers. If
   `elapsed_ms` is anywhere near 2000 see the note at the end of this step.
3. Schedule it monthly — Dashboard → **Integrations → Cron** → new job, or SQL:
   ```sql
   select cron.schedule(
     'refresh-car-insights',
     '0 18 11 * *',                       -- 11th, the day after JPJ publishes
     $$
     select net.http_post(
       url := 'https://<project-ref>.supabase.co/functions/v1/market-insights',
       headers := jsonb_build_object('Content-type', 'application/json',
                                     'apikey', '<your-anon-key>')
     );
     $$
   );
   ```

The function downloads the two most recent yearly **parquet** files (~1 MB total)
rather than the CSVs (~83 MB): an Edge Function is killed at **2 seconds of CPU**,
and parsing the CSVs costs 5–15s.

Two things measured against the live project, worth knowing before you change it:

- These files are **Brotli**-compressed, not Snappy, so `hyparquet-compressors`
  is required — without it the read fails with
  `parquet unsupported compression codec: BROTLI`.
- It decodes **3 of the 7 columns** and that is close to the ceiling. Adding a
  4th (`date_reg`, to filter by month) reliably returned **HTTP 546
  `WORKER_RESOURCE_LIMIT`** — the CPU kill. If you need more columns or a third
  year, split it into one invocation per year: the budget is per request.

### 2c. Seed your first admin
The app's Admin screen is gated on `users.role = 'admin'`, which users can't
set themselves. Seed it once from the SQL editor after signing up in the app:

```sql
update public.users set role = 'admin' where email = 'you@example.com';
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
5. Seller A: **Extend auction** → pick `+1 hour` → the snackbar confirms the
   new time and the **Time left** row jumps by an hour without a reload. The
   sheet never offers an option that would push the run past 7 days from
   `created_at`.
6. Expire it: `update public.auctions set ends_at = now() where id = '<id>';`
   then reopen the Bid tab. The car is **Sold** at the winning amount, a
   `purchases` row exists for B with `method = 'bid'`.
7. `delete from public.listings where id = '<sold id>';` as the seller → 0 rows.

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

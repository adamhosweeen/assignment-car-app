# Supabase setup (build-order Step 2)

This wires the real backend. The app currently runs on an in-memory **fake**
backend; when this is done, we swap the fakes for Supabase in
`lib/app/providers.dart` — no UI changes.

## 1. Create the project
- New project in region **`ap-southeast-1` (Singapore)** — lowest latency to Malaysia.
- Note the **Project URL** and the **anon public** key (Settings → API).
  The **service_role** key must never go into the app.

## 2. Apply the schema
- SQL Editor → paste all of [`migrations/0001_init.sql`](migrations/0001_init.sql) → Run.
- Creates: `profiles`, `listings`, `listing_media`, `conversations`/`messages`
  (schema only), RLS on every table, the signup + `updated_at` triggers,
  realtime on `listings`, and the private `listing-media` storage bucket + policies.

## 3. Enable phone OTP (dev)
- Authentication → Sign In / Providers → **Phone** → enable.
- Add **test phone numbers with fixed OTPs** so development doesn't burn SMS credit.
  A live SMS provider (Twilio or similar) is a paid dependency needed only before release.

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

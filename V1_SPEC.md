# V1 Specification

Companion to `CLAUDE.md`. This document defines the database schema, screens, and
acceptance criteria for version 1.

---

## 1. Database schema (Supabase / Postgres)

Chat tables are defined here even though chat is **not built in v1**, so the schema
doesn't churn when it is added. Do not build chat UI.

### `profiles`

Mirrors `auth.users`, created by trigger on signup.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` PK | FK → `auth.users.id`, cascade delete |
| `email` | `text` | Login identity, from `auth.users.email` |
| `first_name` | `text` | From registration |
| `last_name` | `text` | From registration |
| `dob` | `date` | 18+ enforced by CHECK constraint and the client |
| `phone` | `text` | E.164, e.g. `+60123456789`; plain profile field (no OTP) |
| `state` | `text` | One of the 16 Malaysian states/FTs (§2) |
| `interests` | `jsonb` | Car-interest questionnaire answers, default `'{}'` |
| `display_name` | `text` | Nullable; kept in sync with first + last name |
| `avatar_url` | `text` | Nullable |
| `created_at` | `timestamptz` | default `now()` |

The full schema lives in the single `supabase/migrations/0001_init.sql`, which
resets the project (drops tables, accounts, and uploaded images) before creating
everything. The signup trigger copies `email` and the registration metadata
(`raw_user_meta_data`) into this row. There is deliberately no INSERT policy —
the trigger is the only inserter.

### `listings`

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` PK | default `gen_random_uuid()` |
| `seller_id` | `uuid` | FK → `profiles.id` |
| `status` | `text` | `draft` \| `active` \| `sold` \| `deleted`, default `draft` |
| `make` | `text` | e.g. Perodua |
| `model` | `text` | e.g. Myvi |
| `variant` | `text` | Nullable, e.g. 1.5 AV |
| `year` | `int` | 1970 … current year |
| `mileage_km` | `int` | ≥ 0 |
| `transmission` | `text` | `automatic` \| `manual` |
| `fuel_type` | `text` | `petrol` \| `diesel` \| `hybrid` \| `electric` |
| `body_type` | `text` | `sedan` \| `hatchback` \| `suv` \| `mpv` \| `pickup` \| `coupe` \| `other` |
| `colour` | `text` | |
| `owners_count` | `int` | ≥ 1 |
| `accident_free` | `bool` | |
| `road_tax_expiry` | `date` | Nullable |
| `registration_region` | `text` | `peninsular` \| `sabah` \| `sarawak` |
| `state` | `text` | See §2 |
| `city` | `text` | Free text |
| `price_myr` | `int` | Integer Ringgit, > 0 |
| `negotiable` | `bool` | default `true` |
| `description` | `text` | Nullable, ≤ 1000 chars |
| `created_at` | `timestamptz` | default `now()` |
| `updated_at` | `timestamptz` | trigger-maintained |

Indexes: `(status, created_at desc)`, `(seller_id, status)`.

**Deliberately excluded: plate number and VIN.** Collecting them creates a privacy and
identity-theft exposure with no v1 benefit. Do not add these fields.

### `listing_media`

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` PK | |
| `listing_id` | `uuid` | FK → `listings.id`, cascade delete |
| `storage_path` | `text` | Path in `listing-media` bucket |
| `media_type` | `text` | `photo` \| `video` |
| `position` | `int` | 0 = cover photo |
| `created_at` | `timestamptz` | |

### `conversations` / `messages` — schema only, no v1 UI

`conversations`: `id`, `listing_id`, `buyer_id`, `seller_id`, `created_at`,
`last_message_at`. Unique on `(listing_id, buyer_id)`.

`messages`: `id`, `conversation_id`, `sender_id`, `body`, `message_type`
(`text` | `offer`), `offer_amount_myr` (nullable int), `created_at`, `read_at`.

### Row Level Security

RLS **enabled on every table**. Policies:

- `listings` SELECT: `status = 'active' OR seller_id = auth.uid()`
- `listings` INSERT: `seller_id = auth.uid()`
- `listings` UPDATE / DELETE: `seller_id = auth.uid()`
- `listing_media`: mirrors the parent listing's policy via an `EXISTS` subquery
- `profiles` SELECT: any authenticated user. UPDATE: `id = auth.uid()`

Deletes are **soft** — set `status = 'deleted'`. Never hard-delete a listing row.

### Storage

Bucket `listing-media`, **private**. Path convention:

```
{user_id}/{listing_id}/{uuid}.jpg
```

Storage policy: a user may write only under their own `{user_id}/` prefix. Serve images
through signed URLs.

---

## 2. Malaysian states (dropdown source)

Johor · Kedah · Kelantan · Melaka · Negeri Sembilan · Pahang · Perak · Perlis ·
Pulau Pinang · Sabah · Sarawak · Selangor · Terengganu · WP Kuala Lumpur · WP Labuan ·
WP Putrajaya

`registration_region` is separate from `state` — a Sabah-registered car can be sold in
Selangor, and Malaysian buyers care about this distinction.

---

## 3. Media rules

| Rule | Value |
|---|---|
| Minimum photos | 3 |
| Maximum photos | 12 |
| Photo compression | Longest edge 1920px, JPEG quality 80, target < 500 KB |
| Videos | Optional, max 1 |
| Video limits | ≤ 60 seconds, ≤ 50 MB, downscale to 720p |
| Cover photo | `position = 0`, reorderable by the seller |

Compress **on-device before upload**. Malaysian mobile data is metered and uploading a
raw 12MP photo or an uncompressed 4K video is a guaranteed bad experience.

Upload UI must show per-file progress and allow retry of individual failed files without
restarting the whole submission.

---

## 4. Screens

### 4.1 Splash

Logo centred on white. While shown, restore the Supabase session and check for a saved
draft. Route to Home if a valid session exists, otherwise to Login. Hard cap the
display at **2 seconds** — never block on a slow network.

### 4.2 Login & registration — email + password

*(Amended: replaces the original phone-OTP flow.)*

**Login:** email + password fields, password visibility toggle, inline error text.
"New here? Create an account" link to the registration flow.

**Registration** is a 4-step flow (mirrors the sell flow's step mechanics — progress
bar, back preserves data):

1. **Account** — email (format-validated), password (min 8 chars with at least one
   letter and one digit), confirm password. Inline weak-password / mismatch hints.
2. **About you** — first name, last name, date of birth (date picker capped at
   18 years ago; **under-18 is blocked**), phone number (`+60` prefix, Malaysian
   mobile format validated; no OTP — plain profile data).
3. **Location** — "Use my location" (GPS, coarse; mapped to the nearest state
   centroid) with the manual state picker as fallback when detection fails or is
   denied.
4. **Car interests** *(all optional)* — preferred brands (multi-select), body types
   (multi-select), transmission and fuel preference, budget range in RM. Powers the
   Buy feed's Recommended row (§4.4); editable later from Profile.

On submit, `signUp` sends the registration data as user metadata; the signup trigger
creates the `profiles` row. The router's auth redirect lands the new user on Home.

**No in-app password reset** (out of scope). A forgotten password is resolved
by an operator from the Supabase dashboard (Authentication → Users).

Error cases to handle explicitly: invalid email, weak password, email already
registered, wrong credentials on login, rate limited, no network.

> **Development note:** disable "Confirm email" in the Supabase dashboard
> (Authentication → Sign In / Providers → Email) — the app expects a live session
> straight back from `signUp`.

### 4.3 App shell — bottom navigation

Four tabs using a `StatefulShellRoute` so each tab keeps its own navigation stack.

| Tab | v1 content |
|---|---|
| **Buy** | Minimal feed of all active listings (§4.4). Landing tab. |
| **Sell** | Entry point → My Listings, with a prominent "Sell your car" button |
| **Chat** | Placeholder: centred icon + "Chat is coming soon." |
| **Profile** | View/edit name, phone, location, car interests; log out (§4.8) |

### 4.4 Buy — minimal feed

Newest-first list of every listing where `status = 'active'`, from all sellers. Tapping a
card opens Listing Detail.

*(Amended)* A **"Recommended for you"** horizontal row sits above the newest-first
list when the user has saved interests or a location: the already-fetched active
listings are scored client-side (brand +3, body type +2, within budget +2, same
state +2, fuel +1, transmission +1; score ≥ 1 qualifies, top 10 shown, own listings
excluded). No extra backend query. The feed below is unchanged.

**Explicitly not in v1:** search bar, filters, sort control, price range, location
picker, saved searches, map view, infinite-scroll pagination UI. Fetch the most recent
50 listings and stop — do not build pagination controls.

Reuses the **same listing card widget** as My Listings (§4.6). The only differences are
the query filter and the absence of row actions and status badges.

**Layout (grouped).** Grey `groupedBackground` screen; every card is a white
radius-12 surface with the cover photo flush on top and a 12px text block:
**price** (title3, the hero) → **title** (year make model variant, one line) →
**mileage · state** (footnote) with the posted date at the right in tertiary.
Cards are 16px apart. Two labelled sections via `SectionHeader`:
"RECOMMENDED FOR YOU" (when present) and "NEWEST" (always). The recommended
strip scrolls edge-to-edge — the outer list pads vertically only and each row
insets itself, while the strip carries its own 16px horizontal padding so its
first card aligns with the feed cards. Compact cards are 168px wide (~2.3
visible), price above a one-line title. Skeleton cards mirror the card shape.

- Pull-to-refresh.
- Realtime subscription to `listings` filtered on `status = 'active'`, so a listing
  published on another device appears without a manual refresh.
- The last fetched feed is mirrored into a sqflite read-cache (`listing_cache`),
  emitted immediately on the next launch — so the feed renders instantly on cold
  start and stays browsable offline (photos may show placeholders offline; the
  cache is written only after successful fetches, never authoritative).
- The user's own active listings **do** appear in the feed — do not filter them out.
- Empty state: "No cars listed yet. Be the first — sell your car." with a button to the
  Sell tab.
- Loading state: skeleton cards, not a bare centred spinner.

### 4.5 Sell — create listing (the core of v1)

Seven steps, one screen each, with a thin progress bar. Back preserves entered data.
**The draft is written to sqflite after every step transition.**

| # | Step | Fields |
|---|---|---|
| 1 | Photos | Pick from gallery or camera. Min 3, max 12. Reorder, delete, set cover. Optional video. |
| 2 | Car identity | Make → Model → Variant (optional) → Year |
| 3 | Specs | Mileage (km), transmission, fuel type, body type, colour |
| 4 | Condition | Owners count, accident-free toggle, road tax expiry (optional) |
| 5 | Registration & location | Registration region, state, city |
| 6 | Price | Asking price in RM, negotiable toggle |
| 7 | Review & publish | Full summary, tap any section to jump back and edit |

**Make/model data:** v1 uses a hardcoded Dart list covering common Malaysian makes
(Perodua, Proton, Honda, Toyota, Nissan, Mazda, Mitsubishi, Hyundai, Kia, BMW,
Mercedes-Benz, Volkswagen, Audi, Ford, Isuzu, Subaru, BYD, Tesla) with their common
models, plus an "Other" free-text option. Do not build a database-backed catalogue in v1.

**Publish behaviour:** insert the listing as `draft`, upload media, then flip to `active`
only after every upload succeeds. A partial upload must never produce a live listing with
missing photos.

**Resume behaviour:** if a saved draft exists on app launch, show a dismissible prompt —
"You have an unfinished listing. Continue?"

### 4.6 My Listings

Sectioned list: **Active** then **Sold**. Uses the same card widget and grouped
layout as the Buy feed (§4.4 — grey background, white cards, price → title →
mileage · state, date at right), plus a status badge over the cover and row
actions. The resume-draft banner is a white card too.

Row actions via long-press or an overflow menu: Mark as sold · Edit · Delete
(confirmation dialog required for delete).

Empty state: illustration, "You haven't listed a car yet", and a "Sell your car" button.

Realtime: subscribe to `listings` filtered by `seller_id` so changes appear without a
pull-to-refresh.

### 4.7 Listing detail

Route: `/listing/:id` — a **standalone route taking only a listing ID**, reachable from
both the Buy feed and My Listings.

Layout top to bottom:

1. Full-width swipeable photo gallery with page dots; tap to open fullscreen viewer
2. Price in RM, large and bold, with a "Negotiable" chip if applicable
3. Title: `{year} {make} {model} {variant}`
4. Key facts strip: mileage · transmission · fuel type
5. Grouped spec section: body type, colour, owners, accident-free, road tax expiry,
   registration region
6. Location: city, state
7. Description
8. Posted date

If the viewer is the seller, show Edit / Mark as sold. If not, show a disabled "Chat with
seller" button labelled "Coming soon" — the placement is reserved for v2.

### 4.8 Profile

The signed-in user's own profile. Grouped-section layout (§5 of `CLAUDE.md`).

- Avatar (`ProfileAvatar`): the uploaded photo when `avatar_url` is set, otherwise
  the first letter of the display name on a tinted disc. On the Profile tab the
  avatar carries a camera badge; tapping it opens a sheet — **Take photo / Choose
  from library / Remove photo** (the last only when a photo exists). The pick is
  compressed on-device (longest edge 512, JPEG q85), uploaded to the **public
  `avatars` bucket** at `{user_id}/{uuid}.jpg`, and its public URL saved to
  `profiles.avatar_url`; the previous object is deleted best-effort. A unique
  object per upload means image caches never show a stale photo. Progress is a
  blocking spinner; errors surface as a snackbar; success re-renders via the auth
  stream. Delete account also removes the avatar object.
- Header: full name (derived from first + last name, falling back to the email
  prefix) with the email beneath.
- **Hub** (one grouped card, three chevron rows, each pushes its own screen):
  - **My Info** (`/profile/info`): name, email, phone, location, date of birth,
    member since — read-only, with an Edit action in the app bar.
  - **Car Interests** (`/profile/interests`): brands, body types, transmission,
    fuel, budget — read-only, Edit action in the app bar, plus a footnote tying
    them to the "Recommended for you" row.
  - **Market Insights** (`/profile/insights`): see §4.9.
  The tab itself shows no detail rows — it is header + hub + the two
  destructive rows.
- **Edit Profile** (pushed route from My Info or Car Interests): first/last name, phone, and location are
  editable; the car-interest fields reuse the registration questionnaire widget.
  **Email is read-only** (it's the login identity) and **date of birth is
  read-only** (it protects the 18+ gate).
- **Log out**: destructive row with a confirmation dialog. Signs out via the auth
  repository; the router's redirect guard sends the user to Login automatically.
- **Delete account**: destructive row with a strong confirmation dialog. The app
  removes the user's uploaded photos via the Storage API, then calls the
  `delete_account()` SECURITY DEFINER function, which deletes their messages,
  conversations, listings (+media rows), and finally the auth user (cascading
  the profile). Local caches and any sell draft are cleared; the redirect guard
  returns to Login. Irreversible.

The last fetched profile is mirrored into a sqflite read-cache (`profile_cache`),
so identity, details, and interests render instantly on cold start and remain
complete offline. The cache is written only after successful Supabase reads and
cleared on log out — never authoritative.

Loading/empty/error states follow the same explicit-three-states rule as every other
screen (`CLAUDE.md` §6).

### 4.9 Market insights

A read-only "what Malaysia is buying" screen built from JPJ car-registration data.

**Data source.** data.gov.my "Car Registration Transactions"
(`registration_transactions_car`, JPJ, CC BY 4.0; columns
`date_reg,type,maker,model,colour,fuel,state`). The dataset is **bulk CSV only —
it has no API** (~30–50 MB per year), so nothing in the app calls data.gov.my.

**Pipeline.** `dart run tool/build_car_popularity.dart` downloads the yearly CSVs
(cached under `build/data_gov_my/`), streams them, keeps the rolling 12 months
ending at the latest month present, and writes `supabase/seed/car_popularity.sql`
— an upsert of one row (`id = 'latest'`) into:

```
car_popularity (
  id text pk, period_label text, generated_at timestamptz, source_url text,
  total_registrations integer, data jsonb
)
```

RLS: `select` for `authenticated` only; no write policies (SQL editor / service
role only). Refreshing = re-run the script, paste the new seed. No app release.

**Snapshot contents (`data`).** `top_makers` (15), `top_models` (20, with maker),
`by_state` (top 5 makers for each of the 16 states — dealer-portal "Rakan Niaga"
rows have no state and are excluded here but count nationally), `fuel_split`
(Petrol / Diesel / Hybrid / Electric / Other — all `hybrid_*` fold into Hybrid),
`type_split` (Car / SUV & 4WD / Pickup / MPV / Van), `monthly` (12 points).
JPJ's `W.P. …` spellings are normalised to the app's `WP …`.

**Screen.** Built to fit one screen per view, not one long scroll: a compact
summary card (12-month total + period) → an iOS-style `SegmentedControl`
(`widgets/common/`) with four segments → the selected segment's content →
attribution footer *"Source: JPJ car registrations via data.gov.my (CC BY 4.0).
Generated {date}."* — the attribution is a licence requirement and must not be
removed.

| Segment | Content |
|---|---|
| **Brands** | TOP 5 BRANDS, with a "Show all 15" / "Show top 5" toggle row |
| **Models** | TOP 5 MODELS (maker as sublabel), "Show all 20" toggle |
| **Near you** | POPULAR IN {user's state} (top 5) + smaller-sample footnote. No state on the profile → notice with an "Open My Info" link; state with no JPJ rows → plain notice |
| **Trends** | REGISTRATIONS BY MONTH (`MonthlyBars`) → FUEL TYPE → VEHICLE TYPE |

Switching segments resets the toggle to top 5. Ranked rows use `RankBarRow`
(proportional bar relative to the top entry); no chart package.

**States.** Loading spinner; error → message + Retry; `null` row → "Market
insights aren't published yet"; pull-to-refresh re-fetches. Online-only (no
sqflite cache for this screen).

---

## 5. Acceptance criteria for v1

The version is done when all of the following are true:

1. A new user completes the 4-step email registration (an under-18 date of birth is
   blocked with a clear message) and lands on Home; a returning user logs in with
   email + password.
2. A returning user reopens the app and is not asked to log in again.
3. A user completes all 7 sell steps and publishes a listing with 3+ photos.
4. Force-quitting the app mid-form and reopening it offers to resume the draft with all
   previously entered data intact.
5. The published listing appears in My Listings within 2 seconds, on that device and on a
   second device signed in as the same user, without a manual refresh.
6. The published listing appears in the Buy feed on a **second device signed in as a
   different user**, within 2 seconds, without a manual refresh.
7. Tapping a card in the Buy feed opens Listing Detail with every photo and every field
   rendered.
8. Marking a listing sold removes it from the Buy feed and moves it to the Sold section
   in My Listings, on both devices.
9. Submitting with fewer than 3 photos is blocked with a clear inline message.
10. Turning off the network mid-upload shows a retry affordance, and no half-uploaded
    listing is left in `active`.
11. A signed-in user cannot edit or delete another user's listing (verify by calling the
    API directly, not just by the UI hiding the button).
12. `flutter analyze` reports zero issues.
13. Editing the name, phone, location, or car interests in Profile persists across a
    force-quit and relaunch, and the Recommended row reflects the updated interests.
14. Logging out from Profile returns to the login screen, and the redirect guard blocks
    navigating back to Home until the user signs in again.

---

## 6. Suggested build order

Each step should be a separate session, verified on a real device before moving on.

1. Project scaffold, `app_theme.dart`, and a demo screen exercising every token
2. Supabase project, schema migration, RLS policies, storage bucket
3. Phone OTP auth + go_router auth guard
4. Bottom nav shell with the Chat placeholder tab
5. Freezed models + listings repository (no UI)
6. Sell flow steps 2–6 (forms first — no media yet)
7. sqflite draft persistence + resume prompt
8. Sell step 1: photo picking, compression, reordering
9. Media upload with progress and per-file retry, then publish
10. Listing card widget + My Listings with realtime subscription
11. Buy feed — reuses the card and repository from step 10
12. Listing detail
13. Empty, loading, and error states across every screen
14. Full pass against §5 acceptance criteria, using two devices with two different accounts

Commit to git after each step completes and passes on-device.

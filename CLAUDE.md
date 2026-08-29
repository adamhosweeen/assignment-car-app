
# CLAUDE.md

Project brief for a Malaysian used-car marketplace app. Read this before every task.
Detailed screen specs and database schema live in `V1_SPEC.md` — read that too before
writing any feature code.

---

## 1. Concept

A mobile marketplace for buying and selling used cars in Malaysia. Sellers list their
car with photos and specs; buyers browse listings and negotiate with sellers via in-app
chat. Comparable products: Carsome, Carro, Carousell Motors, Mudah.my.

**Platform:** Android only. Do not add iOS, web, macOS, Windows, or Linux targets.

---

## 2. Version scope

### In v1 — build these

- Splash screen
- Email + password authentication, with a multi-step registration flow collecting
  first/last name, date of birth (18+ enforced), phone number, location (GPS with
  Malaysian-state-picker fallback), and a car-interest questionnaire
- "Recommended for you" row at the top of the Buy feed, scored client-side from
  the user's saved interests and location
- Bottom navigation shell with four tabs: **Buy**, **Sell**, **Chat**, **Profile**
- **Sell module** — multi-step create-listing flow (the core of v1)
- **My Listings** — seller sees their own listings, can mark sold or delete
- **Listing detail** — full view of a single listing with photo gallery
- **Buy feed (minimal)** — newest-first list of all active listings, no search or filters

### Explicitly NOT in v1 — do not build

- Chat / messaging (Chat tab shows a "Coming soon" placeholder)
- Negotiation and offer features
- Search, filters, sorting, or pagination controls on the Buy feed
- Onboarding carousel
- Payments, escrow, inspection booking, financing calculators
- Favourites, saved searches, push notifications
- Seller ratings or reviews
- Admin or moderation tooling
- Bahasa Malaysia localisation

> **Reuse, don't duplicate.** The Buy feed and My Listings are the same listing-card
> widget and the same repository, differing only in query filter (`status = 'active'`
> vs `seller_id = auth.uid()`). Build the card and the repository once. Listing Detail is
> a standalone route taking only a `listingId`, reachable from both.

---

## 3. Tech stack

| Concern | Choice | Notes |
|---|---|---|
| State management | `flutter_riverpod` + `riverpod_annotation` | Code-generated providers |
| Routing | `go_router` | Declarative routes, auth redirect guard |
| Backend | **Supabase** | Postgres + Auth + Storage + Realtime |
| Supabase region | `ap-southeast-1` (Singapore) | Lowest latency to Malaysia |
| Local cache / drafts | `sqflite` | Relational on-device store for listing drafts |
| Models | `freezed` + `json_serializable` | Immutable models, no hand-written `fromJson` |
| Images | `image_picker`, `flutter_image_compress`, `cached_network_image` | |
| Location | `geolocator` | State-level detection at registration; manual picker fallback |
| Fonts | `google_fonts` (Inter) | See §5 |

**Do not add a package without asking first.** If a task seems to need one, propose it
and wait.

### Source of truth

Supabase Postgres is the **only** source of truth. sqflite is a cache and draft store
only:

1. **Listing drafts** — an in-progress sell form, persisted locally after every step so
   a crash or app kill never loses the user's input.
2. **Read cache** — last-fetched listings, so screens render instantly on cold start
   before the network responds.

Never treat the local database as authoritative. Never write user-facing state to it
that isn't also going to Postgres. Unlike Firestore, the Supabase SDK has **no built-in
offline write queue** — do not assume writes will replay when connectivity returns. If a
write fails, surface the error to the user and let them retry.

### Realtime

Use Supabase Realtime so listing changes propagate to connected clients without a
manual refresh. Subscribe on screen mount, dispose on unmount. Never leave a
subscription open behind a disposed widget.

---

## 4. Project structure

```
lib/
  main.dart
  control/                    # everything that isn't UI, models, or helpers,
                              # grouped by feature
    app_router.dart           #   go_router config + auth redirect
    providers.dart            #   app-level Riverpod providers (composition root)
    auth/                     #   Supabase auth repository,
                              #     registration_controller, location_service
    listings/                 #   Supabase listings repository, draft repository,
                              #     listings_providers, sell_controller,
                              #     recommendations_provider
    services/                 #   cross-feature infra: supabase_config,
                              #     error_mapper, sqflite app_database + app_storage
  model/                      # freezed models and pure domain data, by feature
    malaysian_states.dart     #   shared across features
    listing/                  #   listing, listing_draft, listing_media,
                              #     listing_enums, car_catalog, draft_from_listing
    profile/                  #   profile, car_interests
    auth/                     #   registration_data
  utils/                      # flat: formatters, ids, validators, result.dart
                              #   (Result<T>), app_theme.dart (the ONLY place
                              #   colours/type are defined), app_spacing.dart
  widgets/                    # reusable UI primitives, by feature
    common/                   #   button_spinner, grouped_section, select_sheet,
                              #     multi_select_sheet, text_prompt,
                              #     sell_step_scaffold
    listing/                  #   listing_card, listing_card_compact,
                              #     cover_image, media_image, status_badge
    profile/                  #   car_interest_fields
  views/                      # screens, grouped by area
    app_shell.dart            #   bottom-nav shell
    auth/                     #   splash, login, register_flow + register_steps/
    buy/                      #   buy_feed, listing_detail
    sell/                     #   sell_home, sell_flow + steps/
    chat/                     #   chat placeholder
    profile/                  #   profile, edit_profile
    dev/                      #   design_demo_screen
```

Layer-first. Screens live in `views/`, all state management and data access in
`control/`, immutable data types in `model/`. Views never talk to Supabase or sqflite
directly — always through a repository or provider in `control/`. Imports of project
files use `package:assignment/...` form, not relative paths.

---

## 5. Design system — iOS-minimalist

**Target feel:** clean, minimal, iOS-native. Generous whitespace, hairline separators,
flat surfaces, restrained colour.

### Critical rule: Material widgets, iOS styling

Use `MaterialApp` and Material widgets, styled to look iOS. **Do not use `CupertinoApp`
or Cupertino widgets.** Cupertino widgets on Android break the system back gesture,
predictive back, text selection handles, and keyboard behaviour — the app ends up
feeling subtly wrong.

The one exception: use `CupertinoPageTransitionsBuilder` in `pageTransitionsTheme`. The
horizontal slide is the single biggest "feels iOS" win and works correctly on Android.

### Tokens

Every value below lives in `app_theme.dart` / `app_spacing.dart`. **No hardcoded colour,
font size, radius, or spacing value may appear in any widget file.** Pull from
`Theme.of(context)` or the spacing constants. If a needed token is missing, add it to
the theme rather than inlining a value.

**Colour**

| Token | Value | Use |
|---|---|---|
| background | `#FFFFFF` | Screen background |
| groupedBackground | `#F2F2F7` | Behind grouped card sections |
| surface | `#FFFFFF` | Cards, sheets |
| primary | `#007AFF` | Buttons, links, active tab |
| separator | `#C6C6C8` | Hairline dividers |
| label | `#000000` | Primary text |
| secondaryLabel | `#3C3C43` @ 60% | Supporting text |
| tertiaryLabel | `#3C3C43` @ 30% | Placeholders, disabled |
| destructive | `#FF3B30` | Delete, errors |
| success | `#34C759` | Sold badge, confirmations |

**Type** — Inter via `google_fonts`. (Do not attempt to ship SF Pro; it is Apple-licensed
and may not be used in an Android app. Inter is the closest freely licensed match.)

| Style | Size / weight |
|---|---|
| largeTitle | 34 / bold |
| title1 | 28 / bold |
| title3 | 20 / semibold |
| headline | 17 / semibold |
| body | 17 / regular |
| subhead | 15 / regular |
| footnote | 13 / regular |
| caption | 12 / regular |

**Spacing scale:** 4, 8, 12, 16, 20, 24, 32. Screen horizontal padding is 16.

**Radius:** 10 (buttons, inputs), 12 (cards), 14 (sheets, modals).

### Styling rules

- **Elevation is 0 everywhere.** No Material drop shadows. Separate surfaces using
  background colour and 0.5px hairline dividers instead.
- **No ripple.** Set `splashFactory: NoSplash.splashFactory`. Press feedback is a brief
  opacity fade to ~0.6.
- Primary button: full-width, 50px tall, radius 12, 17px semibold, white on `primary`.
- Text fields: filled `#F2F2F7`, no visible border, radius 10, 12px internal padding.
- Bottom nav: 50px, hairline top border, 24px icons with 10px labels, no shadow,
  inactive `secondaryLabel`, active `primary`.
- App bars: `centerTitle: true`, 17px semibold, transparent, `elevation: 0`,
  `scrolledUnderElevation: 0`, hairline bottom border only when content is scrolled.
- Lists of settings/specs use iOS-style grouped sections: rounded 12 card on
  `groupedBackground`, rows separated by inset hairlines.
- Light mode only in v1. Do not build a dark theme, but do not hardcode colours in a way
  that would block adding one later.

---

## 6. Conventions

- **Dart 3, null safety, no `dynamic`** unless parsing untyped JSON at a boundary.
- Models are `freezed` classes. Never pass raw `Map<String, dynamic>` above the data layer.
- All money is **integer Malaysian Ringgit** (`price_myr`). Never use `double` for money.
- All distances are **kilometres** (`mileage_km`), integer.
- Timestamps are `timestamptz` in Postgres, `DateTime` (UTC) in Dart. Convert to local
  only at render time.
- User-facing errors are plain English sentences with a next action. Never surface a raw
  `PostgrestException` or a stack trace.
- Every async UI state must handle all three of loading / empty / error explicitly. A
  bare spinner with no error path is not acceptable.
- Secrets (Supabase URL, anon key) come from `--dart-define`. **Never commit them.**
  The service-role key must never appear in the Flutter app under any circumstance.

---

## 7. Working agreement

- **One screen or one layer at a time.** Do not generate a dozen files in a single pass.
- After any code change, run `flutter analyze` and fix every warning before reporting done.
- Run `dart format .` before finishing.
- Propose the plan and wait for approval before starting a new feature.
- If a requirement here is ambiguous or contradicts a request, **stop and ask.** Do not
  invent product decisions — especially scope, data fields, or auth behaviour.
- Do not add features that aren't in §2. Suggest them instead.

# Contributing — branches, module ownership, and the rules every branch follows

This repo is worked on by several people, each owning a **module** on their own
branch. This file is the working agreement. Two documents are the source of truth
for *what* to build and *how* it must look:

- **`CLAUDE.md`** — scope (§2), stack (§3), project structure (§4), design system
  (§5), conventions (§6), working agreement (§7). Read it before every task.
- **`V1_SPEC.md`** — database schema, RLS, and per-screen specs with explicit
  loading / empty / error states.

> Both files must be **tracked in git** for this to work. Check with
> `git ls-files CLAUDE.md V1_SPEC.md` — if either is missing, a teammate on a
> fresh clone has no rules to follow. Fix that before creating module branches.

---

## 1. Branch model

| Branch | Purpose | Who pushes |
|---|---|---|
| `master` | Always runnable. Only merges via pull request. | nobody directly |
| `feature/<module>-<short-desc>` | One piece of work in one module | the module owner |
| `fix/<module>-<short-desc>` | A bug fix | anyone, but tell the owner |

Rules:

1. **Branch from `master`, merge back via PR.** Never push to `master`.
2. **One module per branch.** `feature/bid-place-bid`, `feature/chat-thread-screen`.
   If you find you need to touch another module, stop and open a separate branch
   (or ask that module's owner) — see §3 for what counts as "shared".
3. **Keep branches short-lived** — days, not weeks. Rebase on `master` before
   opening the PR (`git fetch && git rebase origin/master`), resolve conflicts on
   your side.
4. **Commit messages**: short imperative summary, e.g. `bid: add bids table + RLS`,
   `chat: thread screen with realtime messages`. Prefix with the module name.
5. **No build step.** There is no code generation in this repo — check out a
   branch and `flutter run`. If you see `*.g.dart` or `build.yaml`, they are
   leftovers from an older revision; delete them.
6. `env.json` is yours alone (gitignored). Never commit keys; the service-role key
   never exists in this repo or app.

---

## 2. Module map — who owns which folders

The code is **layer-first with a feature folder inside each layer** (CLAUDE.md §4).
A module = the same feature name across `control/`, `model/`, `widgets/`, `views/`,
plus its SQL block(s) and its section(s) in the docs.

| Module | `lib/control/` | `lib/model/` | `lib/widgets/` | `lib/views/` | SQL (in `0001_init.sql`, frozen — new work = new `000N_*.sql`) | Docs |
|---|---|---|---|---|---|---|
| **auth / profile** | `auth/`, `admin/`, `reports/` | `profile/`, `auth/`, `admin/`, `report/` | `profile/` | `auth/`, `profile/` (hub, my_info, car_interests, edit_profile, admin_users, admin_reports) | `profiles`, `handle_new_user`, Public profiles, avatars bucket, Account deletion, `0002_admin_roles.sql`, `0003_reports_bans.sql` | V1_SPEC §1 profiles, §4.1–4.2, §4.8 |
| **buy / listings** | `listings/` | `listing/` | `listing/` | `buy/`, `sell/` | `listings`, `listing_media`, listing-media bucket, Realtime (listings) | V1_SPEC §3, §4.4–4.7, §4.10 |
| **profiles (public)** | `profiles/` | `profile/public_profile` | `profile/seller_row` | `profile/seller_search`, `profile/seller_profile` | Public profiles | V1_SPEC §4.10 |
| **insights** | `insights/` | `insights/` | `insights/` | `profile/market_insights` | Market insights (`car_popularity`) + `supabase/seed/`, `tool/` | V1_SPEC §4.9 |
| **notifications** | `notifications/` | `notifications/` | — | `profile/inbox` | Notifications (table + 3 triggers) + Realtime (notifications) | V1_SPEC §1 notifications, §4.11 |
| **bid** *(placeholder)* | `bid/` | `bid/` | `bid/` (create) | `bid/` | *none yet* — new file `0002_bids.sql` | add V1_SPEC §1 `bids`, §4.12 |
| **chat** *(placeholder)* | `chat/` | `chat/` | `chat/` (create) | `chat/` | `conversations`, `messages` (exist) — realtime in a new `000N_chat_*.sql` | V1_SPEC §1 (exists), add §4.13 |

**Shared — not owned by any module.** Changes here must be small, additive, and
called out explicitly in the PR description:

- `lib/main.dart`, `lib/control/app_router.dart`, `lib/control/providers.dart`,
  `lib/views/app_shell.dart`
- `lib/utils/*` (`app_theme.dart`, `app_spacing.dart`, `formatters.dart`, …)
- `lib/widgets/common/*`, `lib/widgets/listing/media_image.dart`
- `lib/control/services/*` (`error_mapper`, `image_utils`, sqflite `app_database`
  — a schema change there needs a **version bump + `onUpgrade` branch**)
- `supabase/migrations/0001_init.sql` — frozen; never edited (see §3.4)
- `pubspec.yaml` — **no new package without asking first** (CLAUDE.md §3)

Typical allowed shared edits: add a route, add a provider to the composition root,
add a spacing/colour token. If you need more
than that, it's a conversation in the PR, not a surprise.

---

## 3. Module splitting rules

These make a module self-contained so two people can work in parallel without
stepping on each other.

### 3.1 Every module has the same four pieces
```
lib/model/<module>/       immutable models (+ enums) mirroring the Postgres schema
lib/control/<module>/     <module>_repository.dart      — abstract interface
                          supabase_<module>_repository.dart — the only file that
                                                           talks to Supabase
                          <module>_providers.dart       — the module's queries
                                                           (and any app-scoped
                                                           `provider` entries)
lib/widgets/<module>/     reusable UI for this module only
lib/views/<module>/       screens (one file per screen)
```
Wire the repository in `lib/control/providers.dart` (one `Provider<T>` line in
`appProviders`). Nothing else in the app should construct a repository. Screens
take repositories with `context.read<T>()`, hold the resulting future/stream in
their `State`, and render it through a `FutureBuilder` / `StreamBuilder`.

### 3.2 Dependency direction
- `views` → `control` (providers) → `repository interface` → `model`.
- **Views never import Supabase, sqflite, or another module's views.** Navigate
  to other modules only through `context.push('/route')` (routes live in the
  shared router).
- A module may *read* another module's **providers/models** (e.g. Inbox reads
  `authStateProvider`; Seller page reads `sellerListingsProvider`). It must not
  *write* through another module's repository — ask the owner for a method.
- Shared widgets go in `widgets/common/` only if two modules actually use them.
  Until then they stay in your module.

### 3.3 Data rules (from CLAUDE.md §3/§6 — repeated because they get broken)
- Supabase Postgres is the only source of truth. sqflite is a **read cache or draft
  store only**; never an offline write queue.
- Every fallible call returns `Result<T>`; errors go through `mapError()` and are
  plain English with a next action. Never surface a raw exception.
- Money is integer MYR; distances integer km; timestamps UTC `DateTime`.
- Models are plain immutable classes with hand-written `fromJson`/`toJson`;
  column names *are* the JSON keys (snake_case on the wire, camelCase in Dart).
  Parse through the helpers in `utils/json.dart`, not inline casts.
- A model's `copyWith` takes `Object? field = _unset` for every **nullable**
  field, so passing `null` clears it and omitting it keeps it. Keep that shape —
  the sell flow depends on it (see `test/copy_with_test.dart`).

### 3.4 Backend rules — every Supabase change is a NEW numbered file

**`supabase/migrations/0001_init.sql` is frozen.** It is the v1 baseline (a full
reset + rebuild). Do not edit it — not to add a table, not to tweak a policy, not
to "fix a typo". Every change to the database, storage, or realtime config goes in
a **new file placed after it**:

```
supabase/migrations/
  0001_init.sql                      ← frozen baseline
  0002_bids.sql                      ← next number, <module>_<what>
  0003_chat_realtime.sql
  0004_notifications_bid_kinds.sql
```

Rules for a migration file:

1. **Name**: `NNNN_<module>_<short-desc>.sql`, next free number, zero-padded to 4.
   Numbers are claimed in PR order; if two branches pick the same number, the
   second to merge renumbers.
2. **Header comment**: what it does, which module, and the SETUP.md step it adds.
3. **Paste-alone safe and re-runnable**: `create table if not exists`,
   `create or replace function`, `drop policy if exists` + `create policy`,
   `drop trigger if exists` + `create trigger`, `on conflict do nothing` for seed
   rows. Running the same file twice must not error. Do **not** include drop-table
   or `delete from auth.users` lines — the reset lives only in 0001.
4. **Changing an existing object** (a column, a policy, a function body) is also a
   new file: `alter table … add column if not exists …`, or `drop policy if exists`
   + `create policy`, or `create or replace function`. Never rewrite history in an
   earlier file.
5. **Order matters**: a fresh project applies files in numeric order
   (0001, 0002, …). Your file may depend on everything before it, never after.
6. Add a step to `supabase/SETUP.md` §2 naming the file; the reviewer pastes it
   on the dev project before approving. The PR template asks for the file name.

Design rules that still apply inside any migration:

- RLS on every table. Default to **own-row** policies; anything readable by other
  users goes through a view exposing only safe columns (see `public_profiles`).
- Server-side writes the client must not do (welcome notifications, cascades)
  are `SECURITY DEFINER` functions/triggers, and they only ever act on
  `auth.uid()`'s data or on rows they create themselves.
- Realtime: `alter publication supabase_realtime add table public.<table>;` in the
  migration, and subscribe on screen mount / dispose on unmount in the app (copy
  the `_watch` pattern in `supabase_listings_repository.dart`).
- The service-role key never appears anywhere in this repo.

### 3.5 UI rules
- Material widgets, iOS styling. No Cupertino widgets. Elevation 0, no ripple.
- **No literal colour / size / radius / spacing in a widget file.** Add a token to
  `app_theme.dart` / `app_spacing.dart` (a shared edit — say so in the PR).
- Every async screen handles **loading, empty, and error** explicitly, with a
  retry where a retry makes sense.
- Grouped layouts: grey `groupedBackground` + white cards / `GroupedSection`;
  headers via `SectionHeader`; placeholders via `ComingSoonScreen`.

---

## 4. Playbooks for the two open modules

### Bid (`feature/bid-*`)
1. **Schema first** — new file `supabase/migrations/0002_bids.sql`: `bids(id,
   listing_id, bidder_id, amount_myr int, status text check in (pending, accepted,
   rejected, withdrawn), created_at)` + RLS (bidder reads/writes own; seller reads
   bids on own listings; only the seller updates `status` to accepted/rejected;
   only the bidder to withdrawn) + realtime. SETUP.md step. Reviewer pastes it.
2. The bid module is built: timed auctions in `0014_auctions.sql`, models in
   `model/bid/`, screens in `views/bid/`.
3. Fill `control/bid/bids_repository.dart` (surface is sketched in its doc
   comment), add `supabase_bids_repository.dart`, `bids_providers.dart`, and a
   provider line in `providers.dart`.
4. Screens in `views/bid/`: the tab (my bids as buyer / bids on my cars as seller)
   replaces `BidScreen`'s placeholder; a "Place bid" sheet reached from Listing
   Detail (a shared edit — one button, call it out).
5. Notifications for "new bid on your car" / "your bid was accepted" are a
   **trigger in a migration**, inserting `kind = 'bid_*'` rows — extend the
   `kind` check constraint there (`alter table … drop constraint … ; add
   constraint …`) and the `NotificationKind` enum in the notifications module
   (coordinate with its owner).
6. Docs: V1_SPEC §1 `bids`, new §4.12; CLAUDE.md §2 moves Bid from placeholder to
   built.

### Chat (`feature/chat-*`)
1. Schema and RLS already exist (`conversations`, `messages`, participants only).
   Add a new migration (e.g. `000N_chat_realtime.sql`) with
   `alter publication supabase_realtime add table public.messages;` (+
   `conversations`).
2. Models exist (`model/chat/conversation.dart`, `message.dart`); the interface
   exists (`control/chat/chat_repository.dart`). Implement
   `supabase_chat_repository.dart` + `chat_providers.dart` + a provider line.
3. Screens in `views/chat/`: thread list replaces the placeholder; a thread screen
   `/chat/:conversationId`; "Chat with seller" on Listing Detail becomes live
   (shared edit — the button already exists, disabled).
4. Unread badge on the Chat tab: same pattern as the inbox dot in `app_shell.dart`.
5. Docs: V1_SPEC §4.13; CLAUDE.md §2 moves Chat out of the NOT list.

---

## 5. Definition of done — the PR checklist

A PR is ready to review only when **all** of these are true (the reviewer will run
the first three):

- [ ] `flutter analyze` → **No issues found**
- [ ] `dart format lib test tool` → no changes
- [ ] `flutter test` → all green, and new logic has tests (pure functions and
      models at minimum — see `test/` for the style)
- [ ] Only files inside your module's folders changed, plus explicitly listed
      shared edits (route, provider line, token)
- [ ] No new package in `pubspec.yaml` unless it was agreed beforehand
- [ ] No hardcoded colour / size / radius / spacing in widget files
- [ ] Every new async screen shows loading, empty, and error states
- [ ] Database changes are in a **new** `supabase/migrations/000N_*.sql` (0001
      untouched), paste-alone safe and re-runnable, with a `SETUP.md` step; the
      reviewer has pasted it on the dev project
- [ ] Docs updated: `CLAUDE.md` §2 (scope) and §4 (tree) if folders/features
      changed; `V1_SPEC.md` schema table and screen section
- [ ] Rebased on `master`; generated files not committed; `env.json` not committed
- [ ] PR description says: what module, what changed, which shared files were
      touched and why, and the migration file the reviewer must paste

---

## 6. Review & merge

- At least **one other person** reviews. The module owner merges their own PR once
  approved; nobody merges someone else's.
- Squash-merge, keep the `module: summary` title.
- After merge, everyone rebases their open branches on `master` the same day.
- A broken `master` (analyze/test failing) is fixed before any other merge.

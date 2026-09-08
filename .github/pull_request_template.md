## Module
<!-- one of: auth/profile · buy/listings · profiles · insights · notifications · bid · chat -->

## What changed


## Shared files touched (and why)
<!-- app_navigation / app_routes / providers.dart / app_shell / utils / widgets/common / SQL preamble / pubspec — list each, or "none" -->

## Migration file the reviewer must paste
<!-- supabase/migrations/000N_<module>_<desc>.sql, or "none". 0001_init.sql must be untouched. -->

## Checklist (CONTRIBUTING.md §5)
- [ ] `flutter analyze` — No issues found
- [ ] `dart format lib test tool` — no changes
- [ ] `flutter test` — all green, new logic has tests
- [ ] Only my module's folders + the shared edits listed above
- [ ] No new package without prior agreement
- [ ] No hardcoded colour / size / radius / spacing in widget files
- [ ] New async screens show loading, empty, and error states
- [ ] DB changes are in a new `000N_*.sql` (not 0001), re-runnable; `SETUP.md` step added
- [ ] `CLAUDE.md` §2/§4 and `V1_SPEC.md` updated
- [ ] Rebased on `master`; no generated files or `env.json` committed

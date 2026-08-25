# assignment

A Malaysian used-car marketplace app (Android, v1). See `CLAUDE.md` for the project
brief and `V1_SPEC.md` for screen specs and database schema.

## Getting started

1. Install dependencies:
   ```bash
   flutter pub get
   ```
2. Get the Supabase **Project URL** and **anon key** from whoever set up the project
   (Supabase dashboard → Settings → API). These are never committed — see
   `supabase/SETUP.md`.
3. Copy `env.json.example` to `env.json` and fill in the two values. `env.json` is
   gitignored, so it stays local to your machine.
4. Run the app with those values injected at build time:
   ```bash
   flutter run --dart-define-from-file=env.json
   ```
   In Android Studio: Run/Debug Configurations → Additional run args →
   `--dart-define-from-file=env.json`.

Without `env.json`, the app still runs — it falls back to an in-memory fake backend
instead of Supabase, so you won't see listings from other teammates.

## Code generation

This project uses `freezed`, `json_serializable`, and `riverpod_generator`. After
pulling changes that touch models or providers, regenerate:
```bash
dart run build_runner build --delete-conflicting-outputs
```

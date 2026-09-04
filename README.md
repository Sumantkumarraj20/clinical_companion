# Clinical Companion

Offline-first clinical workflow companion for patient registration, bedside
encounters, investigation tracking, drug lookup, personal clinical notes, and
de-identified CSV export.

The app works locally by default. To enable Supabase sync, build or run with:

```sh
flutter run \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key \
  --dart-define=CLINICAL_OWNER_ID=your-user-id
```

`CLINICAL_OWNER_ID` defaults to `local-practitioner` for local-only use. When
Supabase authentication has an active user, that user ID takes precedence.

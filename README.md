# Clinical Companion

Offline-first clinical workflow companion for patient registration, bedside
encounters, investigation tracking, drug lookup, personal clinical notes, and
de-identified CSV export.

The app starts with the secure configuration screen. Enter the Supabase URL,
Supabase publishable key, Gemini API key, and database password there. Values
are stored in the portable `clinical_data/config.aes` file.

For code generation during development, run:

```sh
dart run build_runner build
```

The Windows portable workflow downloads the SQLite catalogs, generates sources,
and builds the release artifact with `flutter build windows --release`.

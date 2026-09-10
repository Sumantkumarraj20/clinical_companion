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

Deterministic CDSS Engine & Alert Banners: Hook the evaluator directly into DynamicEncounterScreen so when you type vitals or view a patient on ward rounds, alerts (e.g. Sepsis, Hypokalemia, Shock Index, PM-JAY pre-auth checklist) render automatically at the top of the screen.

One-Tap "Apply Order Bundle": Tapping an alert automatically stages the necessary labs and medications without manual typing.

Smart Autocomplete from learned_catalog: Frequency-weighted medication and procedure lookups so common items appear after typing only 2 letters.
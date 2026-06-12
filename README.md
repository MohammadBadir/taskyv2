# Tasky

Tasky is a webapp designed to help you keep track of your course schedules and assignments.
Hosted at: https://taskyv2.web.app

# Release 0.5.3

- Added option to hide courses
- Added important HW and assignments on home page

## Getting Started with Source Code

This project targets pre-null-safety Dart (`sdk: ">=2.7.0 <3.0.0"`) and **must** be built with **Flutter 3.0.5** (Dart 2.17.6) — newer Flutter versions cannot compile it (Dart 3 dropped non-null-safe code; Flutter 3.3 removed `RaisedButton`; Flutter 3.7 introduced name clashes with `NavigationDrawer`/`Badge`).

1. Download Flutter 3.0.5: https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.0.5-stable.zip and extract it side-by-side with any newer Flutter install (e.g. `~/sdks/flutter-3.0.5`).
2. `flutter pub get` (using the 3.0.5 `flutter`)
3. `flutter run -d chrome --no-sound-null-safety` to develop
4. `flutter build web --no-sound-null-safety` then `firebase deploy` to release

Do **not** run `flutter create .` — the `web/` directory (including `index.html` with the Firebase config and the Flutter 3.0-compatible loader script) is checked in, and regenerating it with a newer SDK produces an `index.html` whose loader API is incompatible with Flutter 3.0's `flutter.js` (the app silently never starts).

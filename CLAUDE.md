# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Tasky is a Flutter **web** app (hosted at https://taskyv2.web.app) that lets university students track weekly course progress, schedules, and assignments. Despite the `android/` and `ios/` folders, the app is only built and deployed for web (the Firebase config lives in `web/index.html`, not in Dart). It targets **pre-null-safety Dart** (`sdk: ">=2.7.0 <3.0.0"`), so do not introduce null-safety syntax (`?`/`!`/`late`/`required` keyword).

## Commands

**Toolchain: Flutter 3.0.5 / Dart 2.17.6 ONLY** (installed at `~/sdks/flutter-3.0.5`, separate from the system Flutter). Newer Flutter cannot build this app: Dart 3 dropped pre-null-safety code, Flutter 3.3 removed `RaisedButton` (used by `flutter_auth_buttons`), and Flutter 3.7's material `NavigationDrawer`/`Badge` clash with this app's class and the `badges` package.

```bash
FLUTTER=~/sdks/flutter-3.0.5/bin/flutter
$FLUTTER pub get                                  # Install dependencies (respects committed pubspec.lock)
$FLUTTER run -d chrome --no-sound-null-safety     # Run locally in Chrome
$FLUTTER analyze                                  # Static analysis (flutter_lints include is missing — defaults apply)
$FLUTTER build web --no-sound-null-safety         # Build to build/web
firebase deploy                                   # Deploy build/web to Firebase Hosting (project: taskyv2)
```

`web/` and `pubspec.lock` are checked in. **Never run `flutter create .`** — it regenerates `web/index.html` with a loader API (`onEntrypointLoaded`) that Flutter 3.0's `flutter.js` silently ignores, so the app never starts. `web/index.html` carries the Firebase JS SDK 8.3.2 script tags, the Firebase config, and the `google-signin-client_id` meta tag — all required at runtime (`Firebase.initializeApp()` is called without options and reads the JS-side config).

**Tests:** `test/widget_test.dart` is the unmodified default Flutter counter template — it does not match this app and will fail (it expects a counter + `Icons.add` that don't exist, and `MyApp()` needs Firebase). There is effectively no working test suite; treat this file as a stub to replace, not a baseline.

## Architecture

### State & data flow

Three providers are wired at the top of the tree in `lib/main.dart`:
- `FirebaseAuthService` (plain `Provider`) — wraps `firebase_auth` + `google_sign_in`; exposes `onAuthStateChanged`.
- `UserData` stream (`StreamProvider`) — derived from `onAuthStateChanged`; `null` ⇒ show `SignInWidget`.
- `UserDB` (`ChangeNotifierProvider`) — the central application state object.

`lib/app/app.dart` gates the UI: after Firebase init and the first `UserDB.downloadCourseData()` (tracked by `FirebaseAuthService.isInitialized` / `markInitialized()`), it renders one of three pages via `firstPage(pageNum)` → `HomeWidget` (0) / `NewCourseTableWidget` (1) / `TaskWidget` (2), chosen by `UserDB.defaultPage`. Navigation between pages uses `pushReplacement` from `NavigationDrawer`, which re-runs the same init-gate pattern.

### `UserDB` is the god object — read it first

`lib/app/services/user_db.dart` holds **all** app state and **all** Firestore I/O. Every mutation follows the same pattern: mutate the in-memory field, call `userDocument.update({...})`, then `notifyListeners()`. There is no repository/service layer between widgets and Firestore — widgets call `Provider.of<UserDB>(context)` methods directly. When adding a feature, this is almost always the file to edit.

All user data lives in a **single Firestore document** at collection `testCollection` (yes, literally "test" — this is the production collection), doc id = `uid`.

### Firestore document shape (per user)

```
semesterOrder:            List<String>                       // semester names, ordered
currentSemester:          int                                // index into semesterOrder
courseOrderBySemester:    { <semester>: List<String> }       // course display order
progressMapsBySemester:   { <semester>: courseProgressMap }  // see below
homeworkListBySemester:   { <semester>: List<hwMap> }        // hwMap: {courseName, hwName, due(ms epoch), taskType}
pendingTaskListBySemester:{ "Winter 2020-2021": List<String> } // NOT per-semester — always this literal key
theme:                    int                                // index into Themes.colorPalletes
defaultPage:              int                                // index into Pages.pageNames
displayName:              String
zMiscData:                { lastLogin, currentVer }
```

`UserDB` also caches the *currently selected* semester's slices as flat fields (`courseOrder`, `courseProgressMap`, `homeworkList`, `pendingTaskList`); `changeSemester()` repoints these at the right map entries.

`courseProgressMap` shape:
```
<courseName>: {
  info: { lectureCount, tutorialCount, workshopCount, isHidden? },  // each count is 0, 1, or 2
  data: { "Lecture"|"Tutorial"|"Workshop"|"Singleton": List<int> }  // see encoding below
}
```
`CourseOptions` (`lib/app/models/course_options.dart`) is the typed wrapper for the `info` map; a course with all counts 0 is a "Singleton" (single untyped class).

### Week-progress integer encoding (the core non-obvious mechanism)

Each class type stores marked weeks as a `List<int>`. The course table has `numWeeks = 13` (week indices 0–12). For a given `weekIndex`, presence in the list encodes a `CellStatus` (`lib/app/logic/enums.dart`):

| List contains      | Status     | Meaning                              |
|--------------------|------------|--------------------------------------|
| `weekIndex`        | `Complete` | one session done (check icon)        |
| `weekIndex + 13`   | `Double`   | both sessions done (only when count==2; done_all icon) |
| `-weekIndex`       | `Pending`  | marked pending (grey circle)         |
| absent             | `Empty`    | nothing                              |

Caveat baked into this scheme: `weekIndex 0` collides (`-0 == 0`), so week 0 cannot distinguish Pending from Complete. The cycling logic lives in `standardUpdateCourseProgress` (tap) and `pendingUpdateCourseProgress` (long-press).

### Grid column-index convention

Both `WeekBar` and `CourseCard` render the table as a single `Row` of 31 cells (`List.generate(31, ...)`): **even indices are dividers, odd indices are content**. Index 1 = course-name column, index 3 = class-type label column, indices 5–29 = the 13 week cells. The conversion is `weekIndex = (index - 3) ~/ 2`. Many `UserDB` methods take this raw `index` parameter (see the `//TODO: Get rid of index parameter syntax` notes) rather than a clean `weekIndex`.

### Bulk week operations + undo

Column-header tap/long-press (`markWeekAsComplete` / `markWeekAsPending`) act on a whole week across all **non-hidden** courses. Before mutating, they snapshot that week into `backupMap` (an in-memory, non-persisted `Map<int, Map<String, Map<String, CellStatus>>>`) via `_storeBackup`; the SnackBar "UNDO" action calls `_restoreBackup`. These bulk ops have collapse rules (e.g. if everything is already complete, the week is cleared instead).

### Backward-compatibility code

`downloadCourseData()` and `CourseOptions.fromInfoMap()` contain schema-migration shims (e.g. `homeworkList` → `homeworkListBySemester` fallback, `isHidden` default, out-of-range `currentSemester` reset). The stored schema has evolved across versions, so preserve these guards and add new optional fields defensively rather than assuming keys exist.

## Conventions & gotchas

- **`firstPage(int)` has no `default` case** and can return `null` if `defaultPage` is out of range — keep it in sync with `Pages.pageNames` (`Home`, `Course Table`, `Assignments`).
- **Min width 950px:** `NewCourseTableWidget` shows `ScreenTooSmallWidget` below 950px. The app is desktop/web-oriented.
- **Pending tasks are global, not per-semester** despite the `…BySemester` name — they're always keyed by the literal `"Winter 2020-2021"`.
- **String keys are centralized** in `lib/app/constants/strings.dart` (`Strings.lecture`, `.tutorial`, `.workshop`, `.singleton`, `.version`). Bump `Strings.version` on release. Class-type keys in the `data` map must match these exactly.
- **Themes** are index-based (`Themes.colorPalletes` in `lib/app/constants/themes.dart`); `mainColor`/`secondaryColor` are resolved from `selectedTheme`.
- UI is built with large inline nested-dialog closures (see `new_course_table.dart`); there is no separate form/dialog abstraction layer.

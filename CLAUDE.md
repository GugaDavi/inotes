# iNotes — Architecture & Conventions Guide

Flutter Web notes application (COCUS frontend code challenge).

## Stack

| Layer | Technology |
|---|---|
| Framework | Flutter Web |
| State management | Cubit (`flutter_bloc`) |
| Primary storage | Firebase Firestore |
| Offline storage | Hive (offline-first features) |
| Navigation | go_router |
| Unit tests | `flutter_test` |
| Integration tests | `flutter_test` (full app widget tests) |

## Folder Structure

```
lib/
  core/
    contracts/    # FeatureApp abstract class
    di/           # Locator (GetIt wrapper)
    env/          # .env loading
    errors/       # AppFailure base class only
    result/       # Result<T> sealed class (Success, Failure)
    router/       # AppRouter (all route declarations) + AuthStateNotifier
    ui/           # AppColors, AppSpacing design tokens
  features/
    <feature>/
      domain/           # always present
        entities/       # pure Dart domain objects (no external lib dependencies)
        errors/         # feature-specific failures (extend AppFailure)
        repositories/   # abstract repository interfaces
        usecases/       # one use case per file, dependencies injected via constructor
      data/             # optional
        models/         # DTOs with toJson/fromJson (Firebase, Hive)
        datasources/    # Firestore or Hive calls
        repositories/   # concrete implementations of domain interfaces
      presentation/     # optional
        pages/          # full route screens
        widgets/        # feature-scoped reusable components
        cubit/          # XyzCubit + XyzState (one pair per UI context)
    shared/
      formatters/       # shared formatting utilities
      widgets/          # cross-feature reusable components
    splash/             # initial splash screen (Lottie animation shown before bootstrap)
```

> A feature may contain only the `domain/` folder if it has no data or UI layer yet.

## Conventions

### Dependency flow

```
Cubit → UseCase → Repository → (DataSource?)
```

- Cubits only call use cases — never repositories or datasources directly.
- Use cases only call repositories — never datasources directly.
- Repositories call datasources **only when there are multiple data sources** (e.g. Firestore + local Hive cache). If the repository talks to a single source, it calls it directly — no datasource abstraction needed.

### Domain
- Entities are pure Dart classes — no `toJson`/`fromJson`. Name them with the `Entity` suffix (e.g. `NoteEntity`).
- Use cases must include `UseCase` in the class name (e.g. `CreateNoteUseCase`). The file name mirrors the class: `create_note_use_case.dart`.
- Use cases receive dependencies via constructor (no service locator in domain).
- Use cases expose an `execute` method with named parameters — no `call`, no separate `Params` class.
- Return `Result<T>` (custom sealed class with `Success<T>` and `Failure<T>` in `core/result/result.dart`).
- Use `Result<void>` for operations that produce no return value (e.g. delete).
- Feature-specific failures live in `features/<feature>/domain/errors/` — never in `core/errors/`.

### Data
- Models extend or map to entities. They own serialization logic.
- Create a datasource layer only when the repository aggregates two or more data sources (e.g. remote + offline). A single-source repository calls Firestore directly.

### Cubit
- One `Cubit` per UI context (e.g. `NotesCubit`, `NoteDetailCubit`).
- States use `sealed class` or `freezed` for exhaustive matching.
- Cubits have no knowledge of widgets — they receive use cases via constructor.

### Formatting
- Line width is 120 characters (`page_width: 120` in `analysis_options.yaml`).
- After every file edit, run `dart format <file>` on the changed file.
- For bulk changes across multiple files, run `dart format lib/ test/`.

### Tests

#### Unit tests
- Location: `test/features/<feature>/` mirroring the `lib/` structure.
- Use cases and Cubits must cover 100% of business logic branches.
- DataSources tested with Firestore mocks (`fake_cloud_firestore`).

#### Integration tests
- Location: `test/integration/<feature>/` mirroring the `lib/` structure. Helper in `test/integration/helpers/`.
- Each test pumps the full `App` widget with fake dependencies — no real Firebase, no browser required.
- `fake_app_bootstrap.dart` resets `GetIt.instance`, registers `FirestoreService` backed by `FakeFirebaseFirestore`, initialises all features, and returns `AppTestSetup` (`notifier` + `fakeFirestore`). Pass `notifier` to `App(authNotifier:)`. Use `fakeFirestore` to seed data for scenarios that require pre-existing notes.
- Use `setUpAll` for read-only groups (avoids redundant bootstraps). Use `setUp` for groups that write or mutate state.
- When the note detail modal is open (`opaque: false`), the home page stays in the widget tree. Use `find.byWidgetPredicate` with the field's `placeholder` to target `CupertinoTextField` widgets unambiguously — `CupertinoSearchTextField` wraps a `CupertinoTextField` internally and would otherwise be picked up by `.first`/`.last`.
- Run: `flutter test test/integration/`
- **TODO:** Replace `fake_app_bootstrap.dart` with a real bootstrap that connects to a dedicated Firebase test environment. Tests should seed and clean up data via the real Firestore, making integration tests a true end-to-end safety net.

## Planned Features

| Feature | Status |
|---|---|
| notes (CRUD) | done |

## Firebase

The project uses Firebase Firestore as its backend. To run locally:
1. Set up the project in the Firebase Console.
2. Run `flutterfire configure` to generate `firebase_options.dart`.
3. Do not commit `google-services.json` or `GoogleService-Info.plist`.

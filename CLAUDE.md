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
| Markdown rendering | `flutter_markdown_plus` |
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
        cubits/         # one subfolder per cubit: cubits/xyz_cubit/ holds XyzCubit + XyzState
    shared/
      formatters/       # shared formatting utilities
      widgets/          # cross-feature reusable components (DateField, DateMaskFormatter, buttons/)
      search/           # NoteSearcher — debounced search with isolate-based filtering
      filter/           # DateRangeFilter value object + NoteFilterHelper (date/tag filtering and sort)
      sort/             # SortOption value object (SortField + SortDirection enums)
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
- Entities are pure Dart classes — no `toJson`/`fromJson`. Name them with the `Entity` suffix (e.g. `NoteEntity`, `NoteTagEntity`).
- Use cases must include `UseCase` in the class name (e.g. `CreateNoteUseCase`). The file name mirrors the class: `create_note_use_case.dart`.
- Use cases receive dependencies via constructor (no service locator in domain).
- Use cases expose an `execute` method with named parameters — no `call`, no separate `Params` class.
- Return `Result<T>` (custom sealed class with `Success<T>` and `Failure<T>` in `core/result/result.dart`).
- Use `Result<void>` for operations that produce no return value (e.g. delete).
- Feature-specific failures live in `features/<feature>/domain/errors/` — never in `core/errors/`.

### Data
- Models extend or map to entities. They own serialization logic.
- Create a datasource layer only when the repository aggregates two or more data sources (e.g. remote + offline). A single-source repository calls Firestore directly.
- Use `Locator.registerLazySingleton` when the repository holds mutable state (e.g. an in-memory cache). Use `registerFactory` for stateless repositories.

### Cubit
- One `Cubit` per UI context (e.g. `HomeCubit`, `FilterCubit`). Each lives in its own subfolder under `presentation/cubits/xyz_cubit/`.
- States use `sealed class` or `freezed` for exhaustive matching.
- Cubits have no knowledge of widgets — they receive use cases via constructor.
- Inline lambdas passed to collaborators (e.g. `NoteSearcher(onResult:)`) must be extracted into named private methods on the cubit for readability.
- Cubit-to-cubit communication is done via `BlocListener` in the widget layer — cubits never hold references to other cubits. For example, `FilterCubit` emits filter changes and `HomePage` uses a `BlocListener` to call `HomeCubit.handleFilterChange()`.

### Shared helpers
- Non-UI, non-domain logic that crosses features lives in `features/shared/`.
- `NoteSearcher` (`shared/search/`) is the reference pattern: it encapsulates a debounce `Timer` and a `compute()` call that runs filtering in a separate isolate. Cubits instantiate it with a named callback method and call `dispose()` in `close()`.
- Shared helpers own their async machinery — cubits only call `search()` and `dispose()`.
- Filtering and sorting logic is extracted to `NoteFilterHelper` (`shared/filter/`) — a plain class with static-style methods (`filterByDate`, `filterByTags`, `sort`). Cubits delegate to it instead of owning the logic inline.
- Sort options are represented by `SortOption` (`shared/sort/`), which composes `SortField` and `SortDirection` enums. `FilterOptionsEntity` holds the active `SortOption`; `FilterState.isActive` must include it.

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
- When testing features that use `compute()` / `Isolate.run()`, wrap the interaction + delay in `tester.runAsync()` so the real event loop processes the ReceivePort result. Call `FocusManager.instance.primaryFocus?.unfocus()` inside `runAsync` before it exits to cancel any cursor-blink timers created in the real zone — otherwise they fire on unmounted widgets after the test completes.
- Run: `flutter test test/integration/`
- **TODO:** Replace `fake_app_bootstrap.dart` with a real bootstrap that connects to a dedicated Firebase test environment. Tests should seed and clean up data via the real Firestore, making integration tests a true end-to-end safety net.

## CI/CD

### Git hooks (local)

Hook defined in `.githooks/pre-push`. Activated once per clone via `sh scripts/setup.sh` (runs `git config core.hooksPath .githooks`).

| Step | Command |
|---|---|
| Analyze | `flutter analyze` |
| Test | `flutter test` |

- Runs on every `git push` by default.
- Can be skipped with `git push --no-verify` — not the project default.

### GitHub Actions (remote)

Pipeline defined in `.github/workflows/ci.yml`, triggered manually via `workflow_dispatch`.

| Job | Command | Depends on |
|---|---|---|
| Lint | `flutter analyze` | — |
| Unit Tests | `flutter test test/core test/features test/services` | — |
| Integration Tests | `flutter test test/integration` | — |
| Build Web | `flutter build web --release` | lint + unit tests + integration tests |

- Lint, unit tests, and integration tests run in parallel.
- Build only runs if all three pass.
- A `touch .env` step precedes the test and build jobs because `.env` is a declared Flutter asset.

## Planned Features

| Feature | Status |
|---|---|
| notes (CRUD) | done |
| search notes | done |
| date filter | done |
| note tagging (default tags, max 3 per note) | done |
| filter by tag on home screen | done |
| sort notes (by created/updated, asc/desc) | done |
| markdown support in note content | done |
| custom user tags | planned |

## Firebase

The project uses Firebase Firestore as its backend. To run locally:
1. Set up the project in the Firebase Console.
2. Run `flutterfire configure` to generate `firebase_options.dart`.
3. Do not commit `google-services.json` or `GoogleService-Info.plist`.

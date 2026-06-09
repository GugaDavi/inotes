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
| Tests | Unit tests (`flutter_test`) |

## Folder Structure

```
lib/
  core/
    theme/        # ThemeData, colors, typography
    errors/       # Failure, AppException
    utils/        # shared helpers
  features/
    <feature>/
      domain/           # always present
        entities/       # pure Dart domain objects (no external lib dependencies)
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
- Use cases receive dependencies via constructor (no service locator in domain).
- Use cases expose an `execute` method with named parameters — no `call`, no separate `Params` class.
- Return `Result<T>` (custom sealed class with `Success<T>` and `Failure<T>` in `core/result/result.dart`).

### Data
- Models extend or map to entities. They own serialization logic.
- Create a datasource layer only when the repository aggregates two or more data sources (e.g. remote + offline). A single-source repository calls Firestore directly.

### Cubit
- One `Cubit` per UI context (e.g. `NotesCubit`, `NoteDetailCubit`).
- States use `sealed class` or `freezed` for exhaustive matching.
- Cubits have no knowledge of widgets — they receive use cases via constructor.

### Tests
- **Unit tests only** at this stage.
- Location: `test/features/<feature>/` mirroring the `lib/` structure.
- Use cases and Cubits must cover 100% of business logic branches.
- DataSources tested with Firestore mocks (`fake_cloud_firestore`).

## Planned Features

| Feature | Status |
|---|---|
| notes (CRUD) | pending |

## Firebase

The project uses Firebase Firestore as its backend. To run locally:
1. Set up the project in the Firebase Console.
2. Run `flutterfire configure` to generate `firebase_options.dart`.
3. Do not commit `google-services.json` or `GoogleService-Info.plist`.

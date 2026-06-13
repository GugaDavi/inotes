# iNotes

A Flutter Web notes application — COCUS frontend code challenge.

## About

iNotes lets you create, organize, and manage notes in the browser. Built with Flutter Web, Firebase Firestore as the backend, and a clean feature-based architecture.

Each user accesses their notes through a personal session code — no registration required. The session code acts as the userId for note isolation in Firestore, while Firebase Anonymous Auth ensures only authenticated clients can read or write data.

## Getting Started

### Prerequisites

- Flutter 3.44.1
- Dart 3.12.1
- Firebase project with **Firestore** and **Anonymous Authentication** enabled

### Setup

```bash
# Install dependencies
flutter pub get

# Configure Firebase (generates lib/firebase_options.dart)
flutterfire configure

# Copy the environment template and fill in your Firebase credentials
cp .env.example .env

# Deploy Firestore security rules
firebase deploy --only firestore:rules

# Run on web
flutter run -d chrome
```

### Environment variables

Create a `.env` file at the project root with the following keys (all found in the Firebase Console → Project Settings):

```
FIREBASE_API_KEY=
FIREBASE_AUTH_DOMAIN=
FIREBASE_PROJECT_ID=
FIREBASE_STORAGE_BUCKET=
FIREBASE_MESSAGING_SENDER_ID=
FIREBASE_APP_ID=
FIREBASE_MEASUREMENT_ID=
```

### Run tests

```bash
# Unit tests
flutter test test/core test/features test/services

# Integration tests
flutter test test/integration/
```

## CI/CD

The project uses GitHub Actions with a manual pipeline (`workflow_dispatch`).

| Job | Command |
|---|---|
| Lint | `flutter analyze` |
| Unit Tests | `flutter test test/core test/features test/services` |
| Integration Tests | `flutter test test/integration` |
| Build Web | `flutter build web --release` |

Lint, unit tests, and integration tests run in parallel. The build job only runs after all three pass.

## Architecture

Feature-based clean architecture. See [CLAUDE.md](CLAUDE.md) for the full architecture guide and conventions.

```
lib/
  core/
    contracts/    # FeatureApp abstract class
    di/           # Service locator
    env/          # Environment / .env loading
    errors/       # AppFailure base class
    result/       # Result<T> sealed class (Success, Failure)
    router/       # AppRouter (all route declarations) + AuthStateNotifier
    ui/           # AppColors, AppSpacing design tokens
  features/
    auth/         # Session-code auth (start, restore, clear session)
    notes/        # Notes CRUD + tag selection
    tags/         # Default tags seeded to Firestore; in-memory cache
    home/         # Notes list with search, date filter, and tag filter
    shared/
      widgets/    # Reusable UI components (PrimaryButton, CopyButton, DateField, …)
      search/     # NoteSearcher — debounced search with isolate filtering
      filter/     # DateRangeFilter value object + NoteFilterHelper
      sort/       # SortOption value object (SortField + SortDirection)
    splash/       # Lottie splash screen shown before bootstrap
  services/
    firebase/     # FirebaseClient — init + anonymous sign-in
    firestore/    # Firestore service abstraction
    local_storage/ # SharedPreferences abstraction
```

**State management:** Cubit (`flutter_bloc`)  
**Storage:** Firebase Firestore  
**Navigation:** go_router

---

## Feature Checklist

### Core (required)

- [x] Create note with title and content
- [x] List all notes
- [x] View note detail
- [x] Edit note
- [x] Delete note

### Auth & Security

- [x] Session-code authentication with per-user note isolation
- [x] Anonymous Firebase Auth (Firestore rejects unauthenticated requests)

### Bonus

- [x] Markdown support in note content (preview/edit toggle via eye/pencil icons)
- [x] Search notes (debounced, runs off main thread via isolate)
- [x] Filter notes by date (single day and range)
- [x] Filter notes by tag (unified filter overlay with active filter chips)
- [x] Sort notes (by created/updated date, ascending or descending)
- [x] Note tagging — up to 3 tags per note, 7 default tags seeded to Firestore

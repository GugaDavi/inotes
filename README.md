# iNotes

A Flutter Web notes application — COCUS frontend code challenge.

## About

iNotes lets you create, organize, and manage notes in the browser. Built with Flutter Web, Firebase Firestore as the backend, and a clean feature-based architecture.

## Getting Started

### Prerequisites

- Flutter 3.44.1
- Dart 3.12.1
- Firebase project configured

### Setup

```bash
# Install dependencies
flutter pub get

# Configure Firebase (generates lib/firebase_options.dart)
flutterfire configure

# Run on web
flutter run -d chrome
```

### Run tests

```bash
# Unit tests
flutter test

# Integration tests
flutter test test/integration/
```

## Architecture

Feature-based clean architecture. See [CLAUDE.md](CLAUDE.md) for the full architecture guide and conventions.

```
lib/
  core/
    ui/           # AppColors, AppSpacing design tokens
    errors/       # AppFailure base class
    result/       # Result<T> sealed class (Success, Failure)
    di/           # Service locator
    env/          # Environment / .env loading
  features/
    <feature>/
      domain/       # entities, repository interfaces, use cases
      data/         # models, datasources, repository implementations
      presentation/ # pages, widgets, cubits
    shared/
      formatters/   # DateFormatter and other shared formatters
      widgets/      # Reusable UI components (PrimaryButton, …)
  services/
    firestore/    # Firestore service abstraction
```

**State management:** Cubit (`flutter_bloc`)  
**Storage:** Firebase Firestore (primary) · Hive (offline-first features)  
**Navigation:** go_router

---

## Feature Checklist

### Core (required)

- [x] Create note with title and content
- [x] List all notes
- [x] View note detail
- [x] Edit note
- [x] Delete note

### Bonus

- [ ] Markdown support in note content
- [ ] Search notes
- [ ] Filter notes in list view
- [ ] Sort notes in list view
- [ ] Note tagging / grouping

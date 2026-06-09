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
flutter test
```

## Architecture

Feature-based clean architecture. See [CLAUDE.md](CLAUDE.md) for the full architecture guide and conventions.

```
lib/
  core/         # theme, errors, shared utils
  features/
    <feature>/
      domain/       # entities, repository interfaces, use cases
      data/         # models, datasources, repository implementations
      presentation/ # pages, widgets, cubits
```

**State management:** Cubit (`flutter_bloc`)  
**Storage:** Firebase Firestore (primary) · Hive (offline-first features)  
**Navigation:** go_router

---

## Feature Checklist

### Core (required)

- [ ] Create note with title and content
- [ ] List all notes
- [ ] View note detail
- [ ] Edit note
- [ ] Delete note

### Bonus

- [ ] Markdown support in note content
- [ ] Search notes
- [ ] Filter notes in list view
- [ ] Sort notes in list view
- [ ] Note tagging / grouping

---

## Project Structure

```
lib/
  core/
  features/
    notes/
test/
  features/
    notes/
```

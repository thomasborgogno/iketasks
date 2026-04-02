# Eisenhower Matrix App — Project Guidelines

## Overview

Flutter Android app for task management using the Eisenhower Matrix (4-quadrant urgency/importance grid). Backend: Firebase (Firestore + Auth). Android home widget via `home_widget` package.

## Architecture

**Pattern:** BLoC with Cubit (flutter_bloc ^9.1.1)

```
lib/
├── main.dart              # Entry point — Firebase init, DI (RepositoryProvider + BlocProvider)
├── app.dart               # MaterialApp + AuthCubit routing (sign-in ↔ matrix)
├── core/theme/            # Material Design 3, light/dark themes
└── features/
    ├── auth/              # Google Sign-In, Firebase Auth
    ├── tasks/             # Core CRUD, quadrant assignment, due dates, categories
    ├── categories/        # Category management and filtering
    └── widget_sync/       # Android home widget sync
```

Each feature follows:
- `data/` — Repository (Firebase-backed)
- `domain/` — Model (Equatable)
- `presentation/` — Cubit + State + UI widgets

**Firestore schema:**
- `users/{uid}/tasks/{taskId}` — title, description, dueDate, categoryId, quadrant (`q1`|`q2`|`q3`|`q4`), completed, timestamps
- `users/{uid}/categories/{categoryId}` — name, timestamps

## Code Style

- State management: Cubit only (not full Bloc with events) for this project
- Models extend `Equatable`; override `props` for value equality
- Repository classes are injected via `RepositoryProvider` at `main.dart` level
- Use `intl` for all date formatting; never use raw `DateTime.toString()`
- IDs generated with `uuid` package (`const Uuid().v4()`)

## Build & Test

```bash
flutter pub get
flutter run
flutter test
```

## Conventions & Gotchas

- **Android home widget layouts**: Use only RemoteViews-compatible layouts. `ScrollView` breaks widget inflation — avoid it entirely in widget layouts.
- **TextFields in dialogs**: Manage `TextEditingController` inside a `StatefulWidget` and dispose in the widget lifecycle. Do **not** dispose immediately after `showDialog()`.
- **Quadrant naming**: Quadrants are `q1`–`q4` strings in Firestore. Map: q1=Urgent+Important, q2=Not Urgent+Important, q3=Urgent+Not Important, q4=Not Urgent+Not Important.
- **Connectivity**: `connectivity_plus` is used to detect network state; offline scenarios should degrade gracefully without hard crashes.
- **Theme**: Always support both light and dark via `app_theme.dart`; never hardcode colors directly in widgets.

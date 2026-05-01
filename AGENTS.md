# Eisenhower Matrix App — Project Guidelines

## Overview

Flutter Android app for task management using the Eisenhower Matrix (4-quadrant urgency/importance grid). Backend: Firebase (Firestore + Auth). Two Android home widgets (Glance-based). Supports 10 languages.

## Architecture

**Pattern:** BLoC with Cubit (flutter_bloc ^9.1.1)

```
lib/
├── main.dart                  # Entry point — Firebase init, DI (RepositoryProvider + BlocProvider), service init
├── app.dart                   # MaterialApp + routing (onboarding → sign-in → matrix)
├── core/
│   ├── theme/                 # Material Design 3, light/dark, dynamic color, quadrant palette
│   ├── locale/                # LocaleCubit — SharedPreferences-backed locale selection
│   └── notifications/         # NotificationService — persistent status-bar notification (Q1 tasks)
└── features/
    ├── auth/                  # Google Sign-In + Anonymous Sign-In, upgrade guest→Google
    ├── tasks/                 # Core CRUD, quadrant assignment, due dates, showFromDate, categories
    ├── categories/            # Category management with emoji support
    ├── google_tasks/          # Import from Google Tasks API (incremental OAuth)
    ├── onboarding/            # First-run wizard; SharedPreferences state
    └── widget/                # Two Android home widgets: Matrix (4-quadrant) + Minimal (priority bar)
```

Each feature follows:
- `data/` — Repository (Firebase-backed or SharedPreferences)
- `domain/` — Model (Equatable)
- `presentation/` — Cubit + State + UI widgets

## Features Summary

| Feature | Cubits | Repository | Model |
|---------|--------|-----------|-------|
| auth | AuthCubit | AuthRepository | — |
| tasks | TaskCubit, CompletedTasksCubit | TaskRepository | TaskItem |
| categories | CategoryCubit | CategoryRepository | TaskCategory |
| google_tasks | GoogleTasksImportCubit | GoogleTasksRepository | GoogleTaskItem |
| onboarding | OnboardingCubit | OnboardingRepository | — |
| locale | LocaleCubit | — | LocaleState |
| widget | — | — | — (WidgetSyncService, MinimalWidgetSyncService, WidgetAppearanceService) |
| notifications | — | — | — (NotificationService) |

## Firestore Schema

```
users/{uid}/tasks/{taskId}
  title, description, dueDate, showFromDate, categoryId,
  quadrant ('q1'|'q2'|'q3'|'q4'), completed, createdAt, updatedAt

users/{uid}/categories/{categoryId}
  name (with emoji prefix), createdAt, updatedAt
```

- **`showFromDate`**: task is hidden from the matrix until this date (deferred scheduling).
- **`quadrant` enum in Dart**: `EisenhowerQuadrant` — values `importantUrgent`, `importantNotUrgent`, `notImportantUrgent`, `notImportantNotUrgent`. Extension `.value` maps to `'q1'`–`'q4'`; use `EisenhowerQuadrant.fromValue(str)` to parse from Firestore.

## Quadrant Reference

| Key | Label | Color |
|-----|-------|-------|
| q1 | Urgent + Important | #D7263D (red) |
| q2 | Not Urgent + Important | #1B998B (teal) |
| q3 | Urgent + Not Important | #F4A261 (orange) |
| q4 | Not Urgent + Not Important | #457B9D (blue) |

Color constants live in `core/theme/app_theme.dart`. Never hardcode these hex values in widgets — reference the theme.

## Home Widgets

Two Glance-based widgets registered in `AndroidManifest.xml`:

| Widget | Receiver | Config | Description |
|--------|----------|--------|-------------|
| Matrix | `EisenhowerGlanceReceiver` | `eisenhower_glance_widget_info.xml` (4×4 cells, 320×320dp, 30min update) | Full 4-quadrant view |
| Minimal | `MinimalWidgetReceiver` | `minimal_widget_info.xml` (compact, resizable) | Priority bar with top tasks |

Sync services in `lib/features/widget/`: `WidgetSyncService`, `MinimalWidgetSyncService`, `WidgetAppearanceService`.  
Triggered on: auth changes, connectivity restored, task updates.

## Localization

10 supported locales: `en`, `it`, `es`, `fr`, `de`, `zh`, `pt`, `ru`, `ja`, `ar`.  
Source ARB: `lib/l10n/app_en.arb`. Config: `l10n.yaml`. Output: `AppLocalizations` class.  
Android resource strings mirrored in `android/app/src/main/res/values-*/strings.xml`.  
Always use `AppLocalizations.of(context)!` for UI strings — never hardcode user-visible text.

## Notifications

`NotificationService` (`core/notifications/`) uses `flutter_local_notifications`.  
- Persistent status-bar notification showing top Q1 tasks.
- Toggle stored in SharedPreferences; watchdog timer (1 min) re-shows if user swipes away.
- Strings are localized; call `notificationService.updateLocale(locale)` when locale changes.

## Dependencies (key)

```yaml
flutter_bloc: ^9.1.1         # Cubit-only
firebase_core: ^4.1.1
firebase_auth: ^6.0.2
cloud_firestore: ^6.0.2
google_sign_in: ^7.2.0
home_widget: ^0.8.1          # PINNED — ^0.9.x has Kotlin compile error (HomeWidgetLaunchIntent)
flutter_local_notifications: ^21.0.0
connectivity_plus: ^7.0.0
googleapis: ^16.0.0          # Google Tasks API
dynamic_color: ^1.7.0        # Material You system colors
shared_preferences: ^2.5.3
intl: ^0.20.2
uuid: ^4.5.1
equatable: ^2.0.7
```

## Code Style

- State management: Cubit only (no full Bloc with events).
- Models extend `Equatable`; override `props` for value equality.
- Repositories injected via `RepositoryProvider` at `main.dart` level.
- Use `intl` for all date formatting; never use raw `DateTime.toString()`.
- IDs generated with `uuid` package (`const Uuid().v4()`).
- Always support light/dark via `app_theme.dart`; never hardcode colors directly in widgets.

## Build & Test

```bash
flutter pub get
flutter run
flutter test
flutter analyze
```

**Android toolchain:** JDK 21 at `C:\Program Files\Java\jdk-21.0.11` (configured via `flutter config --jdk-dir`).

## Conventions & Gotchas

- **Android home widget layouts**: Use only RemoteViews-compatible layouts. `ScrollView` breaks widget inflation — avoid it entirely in widget layouts.
- **TextFields in dialogs**: Manage `TextEditingController` inside a `StatefulWidget` and dispose in the widget lifecycle. Do **not** dispose immediately after `showDialog()`.
- **Connectivity**: `connectivity_plus` is used to detect network state; offline scenarios must degrade gracefully without hard crashes.
- **Guest mode**: `AuthState.isAnonymous` (`user.isAnonymous`) distinguishes anonymous from Google users. Use this flag to hide Google-only features (Google Tasks import, Delete Account). Anonymous UIDs use the same Firestore path as Google UIDs — no special handling needed in repositories.
- **Guest upgrade**: `AuthRepository.upgradeToGoogle()` returns `UpgradeResult.success` (UID preserved, data intact) or `UpgradeResult.conflict` (existing Google account — user signed in, guest data abandoned). Show a snackbar for both outcomes.
- **Anonymous Auth**: Must be enabled in Firebase Console → Authentication → Sign-in method → Anonymous.
- **Google Tasks import**: Only available for Google-authenticated users (not anonymous). Performs incremental OAuth requesting `tasks.readonly` scope. Filters out system task lists (names starting with `#`).
- **Onboarding**: `OnboardingCubit` checks `OnboardingRepository.hasCompletedOnboarding()` at launch. Wizard shown before auth flow if not completed.

## Keeping Docs Updated

Update **AGENTS.md** when:
- A new feature or Cubit is added → update Features Summary table and architecture tree.
- A new dependency is added/pinned → update Dependencies section.
- A new gotcha or convention is discovered → add to Conventions & Gotchas.
- Firestore schema changes → update Firestore Schema section.

Update **.github/copilot-instructions.md** when:
- Core code style rules change.
- New critical gotchas affect code generation.

Update **docs/DEV_NOTES.md** when:
- A build issue is resolved with a workaround.
- A new platform-specific quirk is discovered.

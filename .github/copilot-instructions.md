# Copilot Instructions — Eisenhower Matrix App

Flutter Android app (BLoC/Cubit + Firebase). See `AGENTS.md` for full project reference.

## Critical Rules

- **State management**: Cubit only. Never use full Bloc with events.
- **Colors**: Never hardcode hex. Use `AppTheme` constants from `core/theme/app_theme.dart`.
- **Strings**: Always use `AppLocalizations.of(context)!`. Never hardcode user-visible text.
- **IDs**: Generate with `const Uuid().v4()`.
- **Dates**: Use `intl` package. Never use raw `DateTime.toString()`.
- **Models**: Extend `Equatable`, override `props`.
- **Repositories**: Inject via `RepositoryProvider` — never instantiate directly in widgets.

## Quadrants

| Dart enum | Firestore | Label |
|-----------|-----------|-------|
| `importantUrgent` | `q1` | Urgent + Important |
| `importantNotUrgent` | `q2` | Not Urgent + Important |
| `notImportantUrgent` | `q3` | Urgent + Not Important |
| `notImportantNotUrgent` | `q4` | Not Urgent + Not Important |

Parse from Firestore with `EisenhowerQuadrant.fromValue(str)`. Use `.value` to serialize.

## Auth & Guest Mode

- `AuthState.isAnonymous` → hide Google-only features (Google Tasks import, Delete Account).
- `upgradeToGoogle()` returns `UpgradeResult.success` or `UpgradeResult.conflict` — always handle both.

## Android Home Widgets

- **No `ScrollView`** in widget layouts — breaks RemoteViews inflation.
- Two widgets: `EisenhowerGlanceReceiver` (Matrix) and `MinimalWidgetReceiver` (Minimal).
- Sync via `WidgetSyncService` / `MinimalWidgetSyncService` — triggered on task updates.

## Feature Structure Pattern

```
features/<name>/
  data/<name>_repository.dart
  domain/<name>_model.dart        # extends Equatable
  presentation/<name>_cubit.dart
  presentation/<name>_state.dart
  presentation/<name>_page.dart   # or _widget.dart
```

## Key Gotchas

- `showFromDate` on `TaskItem` hides tasks from matrix until that date — respect this filter.
- Google Tasks import only for authenticated (non-anonymous) users.
- `NotificationService.updateLocale(locale)` must be called on every locale change.

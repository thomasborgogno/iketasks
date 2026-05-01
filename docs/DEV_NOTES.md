# Dev Notes — Eisenhower Matrix App

Build issues, platform quirks, and workarounds discovered during development.

---

## Android Build

### JDK Configuration
Flutter Android toolchain requires JDK 21. Configured explicitly:
```bash
flutter config --jdk-dir "C:\Program Files\Java\jdk-21.0.11"
```

### `home_widget` Kotlin Compile Error (PINNED at ^0.8.1)
**Symptom:** `Unresolved reference 'HomeWidgetLaunchIntent'` at build time.  
**Cause:** `home_widget` 0.9.x introduced a breaking Kotlin API change.  
**Fix:** Pin `home_widget: ^0.8.1` in `pubspec.yaml`. Do **not** upgrade until upstream resolves the issue.

```yaml
# pubspec.yaml
home_widget: ^0.8.1   # DO NOT upgrade — 0.9.x Kotlin compile error
```

---

## Android Home Widgets (Glance)

### No ScrollView in Widget Layouts
RemoteViews (used by Android app widgets) does not support `ScrollView`.  
Using it causes silent widget inflation failure — the widget simply won't render.  
Use `ListView`/`GridView` only, or restructure to avoid scrollable containers.

### Widget Not Updating After Install
If the widget appears blank after first install, toggle it off/on from the home screen.  
Widget data is populated on first `WidgetSyncService.sync()` call after auth.

---

## Firebase

### Anonymous Auth Must Be Enabled
Go to Firebase Console → Authentication → Sign-in method → Anonymous → Enable.  
Without this, `signInAnonymously()` throws a `FirebaseAuthException` at launch.

### Firestore Offline Behaviour
Firestore SDK caches reads locally. When offline:
- Reads return cached data silently.
- Writes are queued and committed when connectivity is restored.
- `connectivity_plus` is used to show an offline banner — no hard crash.

---

## Localization

### Adding a New Locale
1. Add `.arb` file: `lib/l10n/app_<locale>.arb`
2. Add locale to `supportedLocales` in `app.dart`
3. Add locale to `initializeDateFormatting` list in `main.dart`
4. Mirror user-visible widget strings in `android/app/src/main/res/values-<locale>/strings.xml`

### NotificationService Locale Update
On every locale change, call:
```dart
notificationService.updateLocale(locale);
```
Forgetting this leaves the persistent notification in the previous language.

---

## Google Tasks Import

### Incremental OAuth
The app requests the `tasks.readonly` scope only when the user opens the import screen — not at sign-in time. If the user revokes scope access mid-session, the import will fail with an auth error; the UI should show a re-authenticate prompt.

### System Task Lists Filtered
Google Tasks includes system lists whose names begin with `#` (e.g. `#hashtag lists`). These are filtered out in `GoogleTasksRepository` and never shown to the user.

---

## Notifications

### Watchdog Timer
`NotificationService` starts a 1-minute watchdog timer. If the persistent Q1 notification is dismissed by the user, the watchdog re-posts it. This is intentional — the notification is designed to be persistent while enabled.

To disable: toggle the notification off in app settings (stored in SharedPreferences).

---

## Testing

```bash
flutter test            # unit + widget tests
flutter analyze         # static analysis (zero warnings policy)
flutter pub get         # after any pubspec.yaml change
```

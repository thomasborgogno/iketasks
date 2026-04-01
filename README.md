# Eisenhower Matrix App (Flutter Android)

Applicazione mobile Flutter per Android per la gestione task con Matrice di Eisenhower.

## Funzionalita implementate

- Login/Logout con Google tramite Firebase Auth.
- Persistenza cloud su Firestore per account utente (`users/{uid}/tasks` e `users/{uid}/categories`).
- Schermata principale con 4 quadranti Eisenhower.
- Task con checkbox completamento, titolo, descrizione opzionale, scadenza opzionale, categoria opzionale.
- CRUD task: creazione, modifica, eliminazione, spostamento tra quadranti (drag and drop).
- Gestione categorie: creazione, eliminazione, filtro per categoria.
- Ordinamento task per data di scadenza.
- Tema chiaro/scuro con Material Design 3.
- Widget Android home screen (grande) con i 4 quadranti e task principali per quadrante.

## Struttura cartelle

```text
lib/
	app.dart
	main.dart
	core/
		theme/
			app_theme.dart
	features/
		auth/
			data/auth_repository.dart
			presentation/auth_cubit.dart
			presentation/auth_state.dart
			presentation/sign_in_page.dart
		tasks/
			data/task_repository.dart
			domain/task_item.dart
			presentation/task_cubit.dart
			presentation/task_state.dart
			presentation/matrix_page.dart
		categories/
			data/category_repository.dart
			domain/task_category.dart
			presentation/category_cubit.dart
			presentation/category_state.dart
		widget_sync/
			widget_sync_service.dart

android/app/src/main/
	AndroidManifest.xml
	kotlin/com/eisenhower/matrix/eisenhower_matrix_app/
		MainActivity.kt
		EisenhowerAppWidgetProvider.kt
	res/layout/eisenhower_widget.xml
	res/xml/eisenhower_widget_info.xml
	res/values/strings.xml
```

## Dipendenze principali

- `flutter_bloc`
- `equatable`
- `firebase_core`
- `firebase_auth`
- `google_sign_in`
- `cloud_firestore`
- `connectivity_plus`
- `home_widget`
- `intl`
- `uuid`

## Setup Firebase (obbligatorio)

1. Crea progetto Firebase.
2. Registra app Android con package:
	 `com.eisenhower.matrix.todo`
3. Aggiungi SHA-1 e SHA-256 in Firebase Console (necessari per Google Sign-In).
4. Scarica `google-services.json` e copialo in:
	 `android/app/google-services.json`
5. In Firebase abilita:
	 - Authentication -> Google
	 - Cloud Firestore

## Firestore data model

- `users/{uid}/tasks/{taskId}`
	- `title` (string)
	- `description` (string|null)
	- `dueDate` (timestamp|null)
	- `categoryId` (string|null)
	- `quadrant` (`q1|q2|q3|q4`)
	- `completed` (bool)
	- `createdAt` (timestamp)
	- `updatedAt` (timestamp)

- `users/{uid}/categories/{categoryId}`
	- `name` (string)
	- `createdAt` (timestamp)
	- `updatedAt` (timestamp)

## Build e installazione Android

```bash
flutter pub get
flutter run -d android
```

Build APK debug:

```bash
flutter build apk --debug
```

Build APK release:

```bash
flutter build apk --release
```

Build AAB (Play Store):

```bash
flutter build appbundle --release
```

Installazione APK su device collegato:

```bash
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

## Note widget Android

- Il widget mostra fino a 3 task per quadrante.
- Il tap sul widget apre l'app.
- L'aggiornamento dati del widget avviene quando cambiano i task in app e via refresh periodico.

## Stato attuale implementazione

Questa base e gia eseguibile e copre il nucleo MVP richiesto. Rimangono come step successivi consigliati:

- Callback checkbox direttamente dal widget per toggle senza aprire app.
- Hardening regole Firestore e suite test avanzata (unit/integration).
- Gestione conflitti multi-device piu sofisticata oltre a `updatedAt`.

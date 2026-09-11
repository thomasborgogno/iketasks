// Web-only Firebase config used solely for local sandbox testing
// (Flutter Web via headless Chromium). Not wired into the Android/iOS build
// paths, which keep using their platform config files as before.
import 'package:firebase_core/firebase_core.dart';

const webTestFirebaseOptions = FirebaseOptions(
  apiKey: 'AIzaSyAw44gIxx-eXdw1idsonNQmAcgWQ5UEK3s',
  authDomain: 'heisenhower-todo.firebaseapp.com',
  projectId: 'heisenhower-todo',
  storageBucket: 'heisenhower-todo.firebasestorage.app',
  messagingSenderId: '118668837979',
  appId: '1:118668837979:web:c133f0b8f7177ab7356b7e',
  measurementId: 'G-1N6Z5HLG8Q',
);

# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Kotlin
-keep class kotlin.** { *; }
-keep class kotlinx.** { *; }
-dontwarn kotlin.**

# Gson / Firestore serialization
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.gson.** { *; }
-dontwarn sun.misc.**

# Glance widget
-keep class androidx.glance.** { *; }

# home_widget
-keep class es.antonborri.home_widget.** { *; }

# App models (Equatable-based)
-keep class com.eisenhower.matrix.** { *; }

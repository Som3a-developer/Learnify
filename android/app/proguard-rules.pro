# --------------------
# Firebase & Google Play Services
# --------------------

# Keep Firebase Auth classes
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Keep Google Play Services (used by Google Sign-In)
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Keep Firebase Messaging / Analytics if used
-keep class com.google.firebase.messaging.** { *; }
-keep class com.google.firebase.analytics.** { *; }

# --------------------
# Gson / JSON (if used for parsing)
# --------------------
-keep class com.google.gson.** { *; }
-dontwarn com.google.gson.**

# --------------------
# Flutter
# --------------------
# Keep Flutter classes to avoid obfuscation issues
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }

# --------------------
# Kotlin coroutines (if used)
# --------------------
-dontwarn kotlinx.coroutines.**

# --------------------
# Reflection Safety
# --------------------
-keepattributes Signature
-keepattributes *Annotation*
# Keep Google Play Core classes
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

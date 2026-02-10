#Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-dontwarn com.google.android.play.core.**
# Google Maps (if used)
# -keep class com.google.android.gms.** { *; }
# -dontwarn com.google.android.gms.**
# Squareup (often used)
# -keep class com.squareup.okhttp.** { *; }
# -keep interface com.squareup.okhttp.** { *; }
# -dontwarn com.squareup.okhttp.**

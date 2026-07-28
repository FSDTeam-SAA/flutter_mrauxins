# Keep all Flutter and AndroidX classes
-keep class io.flutter.** { *; }
-keep class androidx.** { *; }

# Keep all Agora-related classes (if using Agora)
-keep class io.agora.** { *; }

# Keep Just Audio and ExoPlayer-related classes (if using Just Audio)
-keep class com.google.android.exoplayer2.** { *; }
-keep class androidx.media3.** { *; }

# Keep Retrofit or Gson models (if using API serialization)
-keep class com.yourpackage.models.** { *; }

# Prevent R8 from stripping classes needed by reflection
-keepattributes *Annotation*
-keepclassmembers class * {
    @Keep <methods>;
}

-keep class com.hiennv.flutter_callkit_incoming.** { *; }

# Flutter's embedding references Play Core split-install APIs for deferred
# components (dynamic feature delivery). This app doesn't use that, and the
# play-core artifact isn't on the classpath, so R8 can't resolve these -
# safe to ignore since the referencing code path is never exercised.
-dontwarn com.google.android.play.core.**
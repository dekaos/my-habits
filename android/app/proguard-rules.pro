# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Google Play Core (Flutter references but doesn't require)
# These classes are only needed if using deferred components
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }

# Supabase SDK
-keep class io.supabase.** { *; }
-keep class io.github.jan.supabase.** { *; }
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses

# OkHttp (used by Supabase)
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }
-keep class okio.** { *; }

# Kotlin serialization (used by Supabase)
-keepattributes *Annotation*, InnerClasses
-dontnote kotlinx.serialization.AnnotationsKt
-keepclassmembers class kotlinx.serialization.json.** {
    *** Companion;
}
-keepclasseswithmembers class kotlinx.serialization.json.** {
    kotlinx.serialization.KSerializer serializer(...);
}
-keep,includedescriptorclasses class io.supabase.**$$serializer { *; }
-keepclassmembers class io.supabase.** {
    *** Companion;
}
-keepclasseswithmembers class io.supabase.** {
    kotlinx.serialization.KSerializer serializer(...);
}

# Ktor (HTTP client used by Supabase)
-keep class io.ktor.** { *; }
-keep class kotlinx.coroutines.** { *; }
-dontwarn io.ktor.**
-dontwarn kotlinx.atomicfu.**
-dontwarn org.slf4j.**

# Gson (JSON serialization)
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# Keep data classes used with Supabase
-keep class br.com.stuhler.habit_hero.** { *; }

# Flutter Local Notifications
-keep class com.dexterous.** { *; }
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keep interface com.dexterous.flutterlocalnotifications.** { *; }
-dontwarn com.dexterous.flutterlocalnotifications.**

# AndroidX and core Android components needed by notifications
-keep class androidx.core.app.NotificationCompat { *; }
-keep class androidx.core.app.NotificationCompat$* { *; }
-keep class android.app.Notification { *; }
-keep class android.app.NotificationChannel { *; }
-keep class android.app.NotificationManager { *; }

# Timezone library (used by notification scheduling)
-keep class net.iakovlev.timeshape.** { *; }
-dontwarn net.iakovlev.timeshape.**
-keep class com.esri.core.geometry.** { *; }
-dontwarn com.esri.core.geometry.**

# SharedPreferences (commonly used)
-keep class androidx.preference.** { *; }

# SQLite / Database
-keep class androidx.sqlite.** { *; }
-keep class androidx.room.** { *; }

# WorkManager (for background tasks)
-keep class androidx.work.** { *; }
-keep class * extends androidx.work.Worker
-keep class * extends androidx.work.ListenableWorker

# Lifecycle components
-keep class androidx.lifecycle.** { *; }

# Image loading libraries
-keep class com.bumptech.glide.** { *; }
-dontwarn com.bumptech.glide.**

# Reflection-based serialization (common in many packages)
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Keep line numbers for better crash reports
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# Keep custom exceptions for debugging
-keep public class * extends java.lang.Exception


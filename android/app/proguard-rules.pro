# Flutter's own rules are added by the Flutter Gradle plugin.
# Keep rules for plugins that use reflection go here if a release build
# ever crashes while debug works.
-dontwarn io.flutter.embedding.**

# Google Mobile Ads uses WorkManager, whose Room database is created by
# reflection (WorkDatabase_Impl). Without these rules R8 strips it and the
# app crashes at launch ("Failed to create an instance of
# androidx.work.impl.WorkDatabase").
-keep class * extends androidx.room.RoomDatabase { <init>(); }
-keep class androidx.work.impl.WorkDatabase_Impl { *; }
-keep class androidx.work.impl.** extends androidx.room.RoomDatabase { *; }

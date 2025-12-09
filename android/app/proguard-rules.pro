# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Isar Database - Keep native libraries
-keep class io.isar.** { *; }
-keep class dev.isar.** { *; }
-keepclassmembers class * extends io.isar.** { *; }
-keep class * extends io.isar.IsarCollection { *; }

# Keep all model classes for Isar
-keep class com.example.remindlyf.** { *; }

# Keep notification related classes
-keep class com.dexterous.** { *; }

# General
-dontwarn io.isar.**
-dontwarn android.**
-dontwarn javax.**

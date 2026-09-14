# Flutter-specific rules
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# Google Maps (optional - اگر استفاده می‌کنی)
-keep class com.google.android.gms.maps.** { *; }
-dontwarn com.google.android.gms.maps.**

# Gson (اگر استفاده می‌کنی)
-keep class com.google.gson.** { *; }
-dontwarn com.google.gson.**

# Retrofit (اگر استفاده می‌کنی)
-keep class retrofit2.** { *; }
-dontwarn retrofit2.**

# مدل‌های JSON (اختیاری برای جلوگیری از حذف کلاس‌های دیتا مدل)
-keep class *.model.** { *; }

# برای جلوگیری از حذف کدهایی که توسط reflection استفاده می‌شوند
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

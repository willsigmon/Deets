# Add project specific ProGuard rules here.
# Deets Business Card Scanner ProGuard Configuration

# Keep data models
-keep class com.sharedeets.app.domain.model.** { *; }

# Room
-keep class * extends androidx.room.RoomDatabase
-keep @androidx.room.Entity class *
-dontwarn androidx.room.paging.**

# ML Kit
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.** { *; }

# Contacts
-keep class android.provider.ContactsContract$** { *; }

# Google Drive API
-keep class com.google.api.** { *; }
-dontwarn com.google.api.**
-dontwarn org.apache.http.**
-dontwarn javax.annotation.**

# Compose
-dontwarn androidx.compose.**

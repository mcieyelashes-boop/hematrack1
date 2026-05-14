# Platform Setup Guide

## Android
Add permissions in `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

## iOS
Add to `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>Camera access is required for hemangioma monitoring photos.</string>
```

## Notes
- Test on physical devices
- Validate permission flows
- Ensure photo storage access if exporting reports

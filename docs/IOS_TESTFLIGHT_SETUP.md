# iPhone Testing via TestFlight

## Recommended path

### Option A: Codemagic (easiest)
1. Connect GitHub repo to Codemagic
2. Use included `codemagic.yaml`
3. Add Apple Developer credentials
4. Build `.ipa`
5. Publish to TestFlight

## Requirements
- Apple Developer account
- App Store Connect app record
- Bundle identifier
- Signing certificates / provisioning profiles

## Build command
```bash
flutter build ipa --release
```

## After build
- Upload to App Store Connect
- Add internal testers
- Install via TestFlight app on iPhone

## Alternative
- Xcode Cloud
- Fastlane
- Manual Xcode archive

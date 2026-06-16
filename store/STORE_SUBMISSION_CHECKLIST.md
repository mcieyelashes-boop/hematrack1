# Store Submission Checklist

## ✅ Sudah Siap

### Teknis
- [x] Flutter app stabil (1.0.0+1)
- [x] Android signing keystore (lihat scripts/gen_keystore.py + Codemagic env vars)
- [x] Codemagic CI/CD: android-debug, android-release, ios-testflight
- [x] App icon 1024x1024 (assets/images/app_icon.png)
- [x] Adaptive icon Android (foreground + background #EC407A)
- [x] Splash screen (putih bersih + logo)
- [x] flutter_launcher_icons + flutter_native_splash dikonfigurasi
- [x] Privacy policy in-app
- [x] Medical disclaimer in-app
- [x] Permission request flow (welcome screen)
- [x] `debugShowCheckedModeBanner: false`

### Konten
- [x] Short description (max 80 char): store/google_play/short_description.txt
- [x] Full description: store/google_play/full_description.txt
- [x] Release notes v1.0.0: store/google_play/release_notes_v1.0.0.txt
- [x] Content rating jawaban: store/google_play/content_rating_answers.md
- [x] App Store description: store/app_store/app_store_description.txt
- [x] App Store keywords: store/app_store/keywords.txt

## ⏳ Masih Perlu Dilakukan Sebelum Submit

### Google Play Store
- [ ] **Screenshots**: Min 2, max 8 — ukuran 1080x1920px atau 1080x2340px
  → Gunakan emulator atau device nyata, screenshot 5-6 layar utama
  → Layar yang direkomendasikan: Welcome, ChildList, ChildDetail, Camera, Timeline, PDF
- [ ] **Feature graphic**: 1024x500px (banner di atas listing)
  → Buat dengan Canva atau Figma: background pink, logo HemaTrack + tagline
- [ ] **Privacy policy URL**: Upload privacy_policy_screen content ke website atau GitHub Pages
  → Google Play wajib URL publik untuk kebijakan privasi
- [ ] **Email kontak developer**: hematrack.app@gmail.com (buat akun Gmail ini)
- [ ] **Google Play Developer account**: $25 USD one-time fee
  → https://play.google.com/console/signup

### Apple App Store
- [ ] **Apple Developer Program**: $99 USD/tahun
  → https://developer.apple.com/programs/enroll/
- [ ] **Code signing**: Distribution certificate + provisioning profile
  → Set up di Codemagic > App Settings > iOS code signing
- [ ] **Bundle ID**: com.hematrack.app (set di Xcode setelah flutter create .)
- [ ] **App Store Connect**: Buat app listing
- [ ] **Screenshots**: 6.7" (1290x2796), 6.5" (1242x2688), dan iPad jika perlu
- [ ] **Privacy policy URL**: Sama dengan Google Play

## 🔑 Langkah Kritis (Urutan)

1. Generate keystore: `python3 scripts/gen_keystore.py`
2. Set env vars di Codemagic (CM_KEYSTORE_B64, CM_KEYSTORE_PASS, CM_KEY_PASS)
3. Trigger build android-release di Codemagic
4. Host privacy policy (bisa pakai GitHub Pages dari README atau Notion)
5. Buat Google Play Console account
6. Upload APK release + semua metadata
7. Submit untuk review

## 📝 Privacy Policy URL Options

Opsi tercepat untuk host privacy policy:
1. **GitHub Pages**: Buat file docs/privacy-policy.md → enable GitHub Pages
2. **Notion**: Buat halaman public, copy URL
3. **Firebase Hosting**: Free tier, bisa host HTML

Konten privacy policy ada di: lib/screens/privacy_policy_screen.dart

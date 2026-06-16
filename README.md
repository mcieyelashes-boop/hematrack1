# HemaTrack

Aplikasi Flutter untuk monitoring visual **hemangioma anak** — foto baseline, ghost overlay follow-up, grafik tren, penandaan area, dan laporan PDF.

## Fitur

| Fitur | Status |
|-------|--------|
| Welcome screen + permission request | ✅ |
| Profil multi-anak | ✅ |
| Multi-area hemangioma per anak | ✅ |
| Foto baseline dengan panduan posisi | ✅ |
| Follow-up dengan ghost overlay transparan | ✅ |
| Penandaan area manual (polygon freehand) | ✅ |
| Perbandingan baseline vs follow-up | ✅ |
| Grafik tren ukuran relatif mingguan | ✅ |
| Laporan PDF dengan foto embed | ✅ |
| Pengingat mingguan per anak | ✅ |
| Edit profil anak dan area | ✅ |
| Delete cascade dengan konfirmasi | ✅ |
| Privacy policy in-app | ✅ |
| App icon + splash screen | ✅ |
| Android signing (PKCS12) | ✅ |

## Jalankan Lokal

```bash
flutter pub get
flutter run
```

## Build via Codemagic

Repo ini menggunakan [Codemagic CI/CD](https://codemagic.io). Platform Android/iOS **tidak di-commit** — di-generate saat build via `flutter create .`.

### Workflows

| Workflow | Output |
|----------|--------|
| `android-debug` | APK debug untuk testing |
| `android-release` | APK signed untuk Play Store |
| `ios-testflight` | IPA untuk TestFlight |

### Setup Android Release Signing

1. Generate keystore (satu kali):
   ```bash
   pip install cryptography
   python3 scripts/gen_keystore.py
   ```
2. Set environment variables di Codemagic > App Settings > Environment variables:
   - `CM_KEYSTORE_B64` — base64 output dari gen_keystore.py
   - `CM_KEYSTORE_PASS` — password keystore
   - `CM_KEY_PASS` — password key
   - `CM_KEY_ALIAS` — `hematrack` (sudah di yaml)

## Store Submission

Lihat [`store/STORE_SUBMISSION_CHECKLIST.md`](store/STORE_SUBMISSION_CHECKLIST.md) untuk checklist lengkap.

### Privacy Policy (wajib untuk kedua store)

File: `docs/privacy-policy.html`

Host via GitHub Pages:
1. Repo Settings → Pages → Source: **Deploy from branch** → Branch: `main` → Folder: `/docs`
2. URL: `https://mcieyelashes-boop.github.io/hematrack1/privacy-policy.html`

## Arsitektur

```
lib/
├── main.dart                    # Entry point, init storage + repos, cek onboarding
├── models/
│   ├── child.dart               # Model anak (id, name, birthDate, ageString getter)
│   ├── hemangioma_area.dart     # Model area hemangioma
│   └── follow_up_photo.dart     # Model foto follow-up
├── services/
│   ├── app_storage.dart         # JSON persistence + foto + simple key-value prefs
│   ├── child_repository.dart    # CRUD profil anak
│   ├── hemangioma_repository.dart # CRUD area + follow-up
│   ├── reminder_service.dart    # Notifikasi mingguan per-anak (childId-based notif ID)
│   └── report_service.dart      # Generate PDF A4 dengan foto embed
└── screens/
    ├── welcome_screen.dart      # Onboarding pertama launch + request permission
    ├── child_list_screen.dart   # Daftar anak (home)
    ├── child_detail_screen.dart # Detail anak + area cards + edit + laporan
    ├── child_profile_form_screen.dart  # Add/edit profil anak
    ├── hemangioma_area_form_screen.dart # Add/edit area
    ├── camera_baseline_screen.dart     # Kamera baseline + tawarkan polygon marking
    ├── camera_followup_screen.dart     # Kamera follow-up + ghost overlay + size picker
    ├── manual_marking_screen.dart      # Polygon freehand marking di atas foto
    ├── timeline_screen.dart            # Foto timeline + grafik tren fl_chart
    ├── comparison_screen.dart          # Perbandingan baseline vs follow-up
    ├── report_preview_screen.dart      # Preview + export PDF
    ├── onboarding_disclaimer_screen.dart # Disclaimer medis dengan 3 info card
    └── privacy_policy_screen.dart      # Kebijakan privasi lengkap
```

## Disclaimer Medis

HemaTrack adalah alat bantu **dokumentasi visual** saja, bukan alat diagnostik medis. Selalu konsultasikan kondisi anak ke dokter spesialis.

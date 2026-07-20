# FamilyWall Clone — Flutter 1:1 Rebuild

**Status:** Bootstrap (no app code yet)
**Repo:** [`zegh6389/familywall-clone`](https://github.com/zegh6389/familywall-clone)
**Created:** 2026-07-20

A 1:1 Flutter rebuild of the FamilyWall: Family Organizer Android app (`com.familywall` v12.2.2).
Built with the goal of feature and screen parity, written from a clean-room RE brief rather than copying the original Kotlin source.

## Sister project

- **[SecureLife](https://github.com/zegh6389/securelife-android)** — same 1:1-clone pattern for Life360, built in native Kotlin Android. Graphify knowledge graph lives at `graphify-out/` (sister: `C:\Users\Awais\OneDrive\Desktop\life360-clone\graphify-out\`).

## Why Flutter

| Reason | Why it matters here |
|---|---|
| Single codebase Android + iOS | One implementation for both stores; matches the cross-platform growth plan for SecureLife |
| Dart hot-reload | Fast UI iteration matching 50+ screens from RE |
| Widget toolkit | Easier nested layouts than Compose/View system for chat threads, member sheets, dialogs |
| Icon font system | Cleaner icon8 icon swap than resource-folder-by-DPI |
| Cross-platform state management | Hilt → Riverpod pattern transfer from SecureLife is straightforward |

## Stack

- **Flutter 3.27.x** (stable channel)
- **Dart 3.6.x**
- **State**: Riverpod 2.5+
- **Routing**: GoRouter 14+
- **Network**: Dio 5.x + Dio Interceptors (mirrors OkHttp interceptor pattern)
- **Cache/DB**: Drift 2.x (Room equivalent for Dart)
- **Prefs**: shared_preferences + flutter_secure_storage
- **Charts/UI**: fl_chart, table_calendar, flutter_map
- **Auth**: OAuth2 client-credentials via Dio
- **Analytics**: firebase_analytics, segment_analytics, adjust, appsflyer_sdk
- **Notifications**: firebase_messaging + flutter_local_notifications
- **Maps**: google_maps_flutter + geolocator + flutter_background_geolocation
- **Media**: image_picker, photo_view, video_player, chewie, flutter_image_compress
- **Subscription**: in_app_purchase (Play Billing 7) + RevenueCat (replaces Purchasely)
- **Widget (home screen)**: home_widget (Glance Dart equivalent)
- **Icons**: icons8 MCP — see `.docs/icons8-setup.md`

## Setup

```bash
git clone https://github.com/zegh6389/familywall-clone.git
cd familywall-clone
flutter pub get
flutter pub run build_runner build    # Drift codegen
flutter run -d <device>
```

## Build (production)

```bash
flutter build apk --release            # → build/app/outputs/flutter-apk/app-release.apk
flutter build appbundle --release      # → build/app/outputs/bundle/release/app-release.aab
flutter build ios --release            # → build/ios/iphoneos/Runner.app
flutter build web --release            # → build/web/
```

## CI

See [`.github/workflows/ci.yml`](.github/workflows/ci.yml):
- `flutter analyze --fatal-infos`
- `flutter test --coverage`
- `flutter build apk --debug` (artifact: `build/app/outputs/flutter-apk/app-debug.apk`)
- `flutter build web --release` (artifact: `build/web/`)
- Auto-updates `graphify-out/` on every push

## Knowledge graph

Code topology = Graphify. Run locally:
```bash
pip install graphify  # or: uv tool install graphify
graphify update .
```
Output: `graphify-out/GRAPH_REPORT.md`, `graph.json`, `community-*.json`.

The graph is auto-uploaded to GitHub Pages on every release tag.

## Repos
- Project: `https://github.com/zegh6389/familywall-clone`
- Reference RE: `D:\Reverse\FamilyWall\RE_REPORT.md` (private local)
- Obsidian vault: `[[projects/familywall-clone]]` + `[[projects/FamilyWall-RE-Findings]]`

## License

Private (solo dev). Not for redistribution.

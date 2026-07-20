# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Bootstrap (2026-07-20)

#### Added
- Flutter 3.27.1 project skeleton (mobile target)
- Android package `com.securelife.familywall`
- iOS bundle `com.securelife.familywall`
- Material 3 theme tokens scaffold
- Riverpod state management
- GoRouter routing scaffold
- Dio HTTP client + interceptor pattern
- Drift local DB schema definitions
- Riverpod-based `MultiFamilyManager` (one user, multiple family circles)
- Android `home_widget` bridge for `CalendarWidgetProvider` etc.
- `flutter_local_notifications` action buttons (`REPLY/COMMENT/LIKE/CHECKIN`)
- `firebase_messaging` + `appsflyer_sdk` + `segment_analytics` + adjust attribution
- `flutter_background_geolocation` service (BG location + panic)
- `flutter_ics_parser` for ICS calendar import
- `in_app_purchase` + `purchases_flutter` subscription stack
- Documentation: `docs/RE_REPORT.md` (mirrors local `D:\Reverse\FamilyWall\RE_REPORT.md`)
- Documentation: `docs/ARCHITECTURE.md`, `docs/API_CONTRACT.md`, `docs/UI_LAYOUT_REFERENCE.md`
- `.github/workflows/ci.yml` — Android + Web + analyze + test + graphify-refresh
- Obsidian vault notes: `[[projects/familywall-clone]]`, `[[projects/FamilyWall-RE-Findings]]`
- Graphify config `.graphify.yml`

#### Security
- OAuth2 client secret moved off-device; mobile app exchanges via our backend proxy
- Keychain for tokens (iOS) + EncryptedSharedPrefs (Android)
- Network security config restricts cleartext to dev domains only

### Planned
- Phase A: Auth (login, email verify, password)
- Phase B: Dashboard + 4-tab bottom nav + member bottom sheet (draggable)
- Phase C: Wall (chat threads, messages, attachments)
- ... [see docs/UI_LAYOUT_REFERENCE.md for full phase list]

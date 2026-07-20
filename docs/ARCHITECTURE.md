# FamilyWall Clone — Architecture (Flutter)

> **Single source of truth**: the canonical architecture comes from the RE findings at `D:\Reverse\FamilyWall\RE_REPORT.md` and the structured summary at `[[projects/FamilyWall-RE-Findings]]`. This document is the Flutter translation of that spec.

## High-level (Flutter terminology → Kotlin RE)

| Original (RE) | Flutter equivalent | Where it lives |
|---|---|---|
| `@HiltAndroidApp FamilyWallApplication` | `ProviderScope` + `MyApp` widget | `lib/main.dart`, `lib/app.dart` |
| `MainActivity` (single activity) | `MyApp` with `MaterialApp.router` | `lib/app.dart` |
| `BottomNavigationView` (custom 4 tabs) | `NavigationBar` (Material 3) | `lib/features/home/widgets/family_bottom_nav.dart` |
| `com.familywall.backend.net.AndroidMultipartHttpClient` | `Dio` + `Interceptor`s (OkHttp analogue) | `lib/data/api/dio_client.dart`, `lib/data/api/interceptors.dart` |
| `com.familywall.backend.cache.CacheResultLiveData` | `Riverpod` providers + `AsyncValue<T>` | `lib/data/cache/*.dart` |
| `Room` entities + DAOs | `Drift` @DataClass + DAOs | `lib/data/db/` |
| `com.familywall.applicationmanagement.OnBootReceiver` | `flutter_background_service` periodic task | `lib/services/boot.dart` |
| `FcmListenerService` | `firebase_messaging` `onMessage` handler | `lib/services/fcm.dart` |
| `LocationProvidersChangedService/Receiver` | `flutter_background_geolocation` event stream | `lib/services/location.dart` |
| `ApplicationBackgroundManager$FamilyWallJobService` | `workmanager` periodic task | `lib/services/jobs.dart` |
| `Hilt @Inject` + `Singleton` | `riverpod` `Provider` + `ProviderScope` overrides | `lib/di/providers.dart` |
| `MultiFamilyManager` (one user, multiple circles) | Riverpod `StateProvider<List<Family>>` | `lib/features/family/multi_family_provider.dart` |
| `CalendarWidgetProvider` (Glance) | `home_widget` + Android `AppWidgetProvider` + iOS WidgetKit bridge | `lib/widgets/calendar_widget.dart`, native pieces in `android/app/src/main/kotlin/com/securelife/familywall/widget/` |
| `NotificationsActionsIntentService` (REPLY/COMMENT/LIKE/CHECKIN) | `flutter_local_notifications` action buttons | `lib/services/notifications.dart` |
| `IcsReceiverActivity` (handles `application/ics`) | `flutter_ics_parser` + intent filter hook | `lib/features/event/ics_import.dart` |
| `com.familywall.provider.FamilyProvider` | None — pure Dart | n/a |
| `com.familywall.provider.GenericFileProvider` | `path_provider` + `share_plus` | `lib/util/share.dart` |
| OkHttpTrafficStatInterceptor | `Dio` interceptor that records timing + fires analytics | `lib/data/api/interceptors/traffic_stat.dart` |
| `Log.init()` wrapper | `logging` package | `lib/util/log.dart` |
| `com.familywall.util.log.Log` | Same | Same |

## Feature module map

Each module under `lib/features/<name>/` mirrors one Kotlin package:

| Flutter module | RE package | UI scope |
|---|---|---|
| `home/` | `com.familywall.app.main`, `dashboard` | MainActivity, DashboardActivity |
| `chat/` | `app.message`, `app.shout`, `app.postmedia` | IM threads, messages |
| `family/` | `app.family`, `app.member`, `multifamily` | Family circle, members, multi-family |
| `event/` | `app.event`, ICS import | Calendar events, ICS import |
| `location/` | `app.location`, `app.checkin` | Check-ins, background tracking |
| `panic/` | `app.panic` | SOS button |
| `budget/` | `app.budget` | Family budget |
| `meal/` | `app.mealplanner` | Meal planner |
| `tasks/` | `app.task` | Todo |
| `birthdays/` | `app.bdaytracker` | Birthday tracker |
| `timetables/` | `app.timetables` | School timetables |
| `reminder/` | `app.reminder` | Reminders |
| `media/` | `app.gallery`, `app.photo`, `app.video` | Shared photos, videos |
| `filer/` | `backgroundupload`, `app.filer` | Background upload |
| `premium/` | `app.premium` | Subscription flow |
| `login/`, `logout/`, `password/`, `firstuse/`, `welcome/` | app.login.* etc. | Auth/onboarding |
| `settings/` | `app.settings` | Settings hub (10+ subpages) |
| `account/` | `app.account` | Account |
| `help/`, `terms/`, `privacy/`, `rating/` | same | Support |

Shared:
- `lib/widgets/` — custom Flutter widgets (draggable member sheet — RE: `memberSheet`; selected-member sub-sheet — RE: `view_selected_member_sheet.xml`)
- `lib/theme/` — Material 3 theme tokens
- `lib/data/api/` — Dio client + interceptors
- `lib/data/db/` — Drift schema mirroring Room DAOs
- `lib/data/model/` — domain models (Member, Family, Message, Event, etc.)
- `lib/di/` — Riverpod provider wiring (mirrors Hilt modules)
- `lib/services/` — Platform integrations (FCM, location, widgets, notifications)
- `lib/util/` — Cross-cutting helpers

## Authentication

OAuth2 client-credentials flow (RE: `OAUTH_CLIENT_ID=3170dae7...`, `OAUTH_CLIENT_SECRET=dBs2Bwf...`).
- **In production RE app**: client_secret baked into APK (BAD)
- **In our clone**: client_secret lives only on our backend; mobile gets short-lived JWT
- Token exchange: `POST https://api.familywall.com/oauth/token` (when we have control) or our auth proxy endpoint
- Token storage: `flutter_secure_storage` (Keychain on iOS, EncryptedSharedPrefs on Android)

## Networking layer (mirrors `com.familywall.backend.net.*`)

```
lib/data/api/
├── dio_client.dart            # base Dio instance, baseUrl=https://api.familywall.com/api
├── interceptors/
│   ├── auth.dart              # Bearer token injection
│   ├── retry.dart             # exponential retry
│   ├── cache.dart             # OkHttp cache analogue
│   ├── traffic_stat.dart      # OkHttpTrafficStatInterceptor port
│   └── firebase_perf.dart     # perf metric tracking
├── endpoints/
│   ├── auth.dart              # /oauth/token
│   ├── member.dart            # /members/...
│   ├── chat.dart              # /messages/...
│   ├── location.dart          # /location/...
│   ├── event.dart             # /events/...
│   └── ...
└── multipart.dart             # AndroidMultipartHttpClient analogue
```

## Local DB (Drift, mirrors Room)

| Room (RE) | Drift (Flutter) | Table |
|---|---|---|
| `FamilyProvider.db` | `lib/data/db/database.dart` (DriftDatabase) | all entity classes live in same file family |
| `IMMessageBean` | `lib/data/db/tables/messages.dart` | `messages` |
| `IMThreadBean` | `lib/data/db/tables/threads.dart` | `threads` |
| `IMParticipantBean` | `lib/data/db/tables/participants.dart` | `participants` |
| `CacheControlBean` | `lib/data/cache/cache_control.dart` | cache invalidation table |
| `IMThreadsAndMessages` (joined) | `lib/data/db/dao/messages_with_threads.dart` | DAO with @DriftAccessor |

## Permissions mapping

| RE permission | Flutter requirement |
|---|---|
| `INTERNET` | auto on Android+Flutter, no runtime prompt |
| `ACCESS_FINE_LOCATION` | `Geolocator.requestPermission()` |
| `ACCESS_BACKGROUND_LOCATION` | `Permission.locationAlways.request()` |
| `READ_MEDIA_IMAGES` | `image_picker` + Android 13+ photo picker |
| `RECORD_AUDIO` | (not used in UI directly, derived from system) |
| `READ_CALENDAR` / `WRITE_CALENDAR` | `add_2_calendar` + permission_handler |
| `READ_CONTACTS` / `WRITE_CONTACTS` | `flutter_contacts` + permission_handler |
| `POST_NOTIFICATIONS` | `flutter_local_notifications.requestPermissions()` |
| `ACTIVITY_RECOGNITION` | `flutter_background_geolocation.activity_recognition` |

## State management policy

- **Global state**: Riverpod ProviderScope at root
- **Per-screen state**: `flutter_hooks` + Riverpod
- **Per-widget**: `flutter_hooks.useState()` when no cross-widget coordination needed
- **Network state**: `AsyncValue<T>` wrappers from Riverpod (Loading / Data / Error)

## Build pipeline order

1. Compile Dart → Kernel (Dart front-end)
2. compile_runner codegen (`build_runner build`)
3. `flutter pub run icons8_codegen` (if used)
4. `flutter build apk` → AAPT → D8 → DX → ZIP signing → ZIP align

## Cross-cutting

| Concern | Flutter package |
|---|---|
| Crash reporting | `firebase_crashlytics` |
| Performance | `firebase_performance` (optional) |
| Analytics | `firebase_analytics` + `segment_analytics` + `appsflyer_sdk` |
| Feature flags | `package_info_plus` + custom LaunchDarkly (or skip for v1, reuse SecureLife's pattern) |
| Logging | `logging` package, custom formatter mirroring `com.familywall.util.log` |
| Date/time | `intl` + `timezone` |

## Next steps (after this plan)
1. Wait for Flutter SDK install
2. `flutter create` with `org=com.securelife`, `project_name=familywall_clone`
3. Move Flutter `app/` into `familywall-clone/app/`
4. Replace default `pubspec.yaml` with the one above
5. Drift codegen
6. Wire first screen: login → home → 4-tab nav (mirrors RE: MainActivity → DashboardActivity)

# FamilyWall — UI Layout Reference

> **Extracted from** FamilyWall v12.2.2 (RE date 2026-07-20). 50+ activities, 15+ services, 4-tab bottom nav, nested bottom sheets.
> **Use when** building screens in `lib/features/<name>/` to keep pixel parity with RE.

## Root navigation (mirrors `MainActivity` → `DashboardActivity`)

```
RootActivity
├── SplashFragment (auto-dismissed)
├── OnboardingCluster
│   ├── WelcomeFragment (first launch)
│   ├── LoginFragment (email or phone)
│   ├── PasswordFragment
│   ├── EmailVerificationFragment
│   ├── FirstUseTermsFragment
│   └── PermissionPrimerFragment (location/contacts/notifications)
├── DashboardActivity (the "home")
│   ├── BottomNav (4 tabs)
│   ├── MemberBottomSheet (draggable, peek/half/expanded)
│   │   ├── Member list (with section pills — Chat / Family / Places)
│   │   ├── SelectedMemberSheet (draggable sub-sheet)
│   │   │   ├── Avatar (large, animated)
│   │   │   ├── Battery pill
│   │   │   ├── Place pill
│   │   │   ├── Action row (Route / Call / Message / Check In)
│   │   │   ├── Member details scroll
│   │   │   └── Activity log
│   │   └── MemberDetailSheet (modal, separate)
│   │       ├── Cover photo
│   │       ├── Profile fields
│   │       ├── Recent activity
│   │       ├── Settings shortcuts
│   │       └── [no embedded map]
│   ├── ChatThreadActivity (parent: Dashboard)
│   ├── ThreadCreateActivity (modal, exported=true → share intent)
│   │   └── Action: NOTIFICATION_PREFERENCES category also MAIN
│   └── UploadDispatcherResultActivity (no UI, dispatched after uploads)
└── SettingsActivity
    ├── AccountSubsettings
    ├── ProfileSubsettings
    ├── NotificationsSettingsActivity (NOTIFICATION_PREFERENCES)
    ├── LanguageActivity (sub-form PREF_LANGUAGE SharedPrefs)
    ├── PremiumPlanPickerActivity
    ├── PrivacySettingsActivity
    ├── HelpCenterActivity
    ├── TermsActivity
    ├── PrivacyPolicyActivity
    ├── RatingFragment (rate-this-app prompt)
    ├── DebugMenuActivity (devtools)
    ├── DevToolsActivity (devtools)
    └── LogoutFragment
```

## 4-tab bottom nav (`com.familywall.app.main.MainActivity`'s nested nav)

Per RE: tabs appear after login. **Custom BottomNavigationView-style, not the system BottomNavigationView.**

```
Tab 1: HOME       (dashboard with map + member sheet)
Tab 2: WALL       (chat + shouts + photo stream)
Tab 3: SAFETY     (panic, crime reports, road-side, bubbles)
Tab 4: FAMILY     (members + invitation + settings)
```

(Note: the Live360 family-wall clone doesn't always have a 4th tab; some navigations use a drawer. We'll standardize on a 4-tab bottom nav matching the established pattern.)

## Member bottom sheet — exact dimensions (RE-mirrored)

| State | Height (dp) | Content |
|---|---|---|
| Peek | 156 | Section pills header + 4 member rows |
| Half | 0.52 * screen | Member list full + small map preview |
| Expanded | 64 (fixed drag-from-top handle) | Full member list + map expanded + quick controls |

## Widgets (Glance-based, RE: `com.familywall.appwidget` + `com.familywall.app.widgets`)

| Widget | Appearance | Refresh |
|---|---|---|
| `CalendarWidgetProvider` | Month view | On data change |
| `CalendarMonthWidgetProvider` | Compact month | On data change |
| `TasklistWidgetReceiver` | Upcoming tasks list | On data change |
| `SpecialDayTrackerWidget` | Birthday/event countdowns | On data change |
| `CalendarTimelineWidget` | Day timeline | On data change |

## Settings hub structure (10+ subpages)
- Account
- Profile
- Notifications (with full NotificationListActivity)
- Language
- Premium
- Privacy
- Help Center
- Terms
- Privacy Policy
- Rate this app
- (Debug) DevTools
- Logout

## Onboarding flow (RE: `app.firstuse`)

```
FirstLaunch → WelcomeFragment → optionalSignInFragment
  → LoginFragment → (if new) EmailVerificationFragment → PasswordFragment
  → PermissionPrimerFragment (location, contacts, calendar, notifications)
  → FirstUseTermsFragment → MainActivity (with hint dialogs)
```

## Style tokens (RE: `R.style.*` + Flutter tokens to derive)

| Token | RE value (sampled) | Flutter target |
|---|---|---|
| Brand primary | `ca-app-pub-9099561257831895` | Coral `#FF6B50` (reuse SecureLife palette) |
| Theme | `@style/Theme.FamilyWall.Light` | Material 3 light + dark |
| Card radius | `8dp` | `8.dp` |
| Button radius | `4dp` | `10.dp` (M3 button) |
| Bottom sheet radius | `16dp` | `16.dp` |
| Section pill | `R.layout.view_section_pill` | Custom widget `SectionPill()` |
| Section pill icons | icons8 PNG (re-stored RE icons) | icons8 SDK pulls |
| Body font | Roboto + Inter for headings | Roboto + Inter |

## Cross-cutting components

- **Drag handle** (`view_drag_handle.xml`): 36dp wide × 4dp height, top of every bottom sheet
- **Section pill row**: 4 pills across, equal width, icon + label
- **Avatar sizes**: 32 / 48 / 64 / 96 (sm/md/lg/profile screen)
- **Battery pill**: round-cornered bg + battery icon + percentage text — color coded (red ≤20, amber ≤50, green >50)
- **Place pill**: round-cornered bg + pin icon + place name

## Implementation phases (planned)

1. **Phase A** — Auth (login, email verify, password)
2. **Phase B** — Dashboard + 4-tab bottom nav + member bottom sheet (draggable)
3. **Phase C** — Wall (chat threads, messages, attachments)
4. **Phase D** — Map + check-ins + panic
5. **Phase E** — Family invites + multi-family switcher
6. **Phase F** — Media (photos, videos) + background upload
7. **Phase G** — Calendar + ICS import
8. **Phase H** — Reminders / Tasks / Timetables / Birthdays
9. **Phase I** — Budget + Meal planner
10. **Phase J** — Notifications + FCM
11. **Phase K** — Premium subscription
12. **Phase L** — Widgets (home screen)
13. **Phase M** — Settings + language localization
14. **Phase N** — Polish, share intent, rate-this-app, accessibility

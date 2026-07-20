# RE_REPORT.md — Mirror

> This file mirrors the canonical reverse-engineering report at `D:\Reverse\FamilyWall\RE_REPORT.md` (12 sections, full data) for in-repo visibility. Edit the canonical at `D:\Reverse\FamilyWall\`; this mirror updates via repository sync.

For full report, see:
- **Canonical (on disk):** `D:\Reverse\FamilyWall\RE_REPORT.md`
- **Obsidian note:** `[[projects/FamilyWall-RE-Findings]]` (in `C:\Users\Awais\Documents\ObsidianVault\`)
- **Smali:** `D:\Reverse\FamilyWall\apktool_out\` (68,237 files)
- **Decompiled Java:** `D:\Reverse\FamilyWall\jadx_out\` (34,240 .java files)

---

## TL;DR

| Field | Value |
|---|---|
| Package | `com.familywall` |
| Version | 12.2.2 (code 2015945937) |
| minSdk / targetSdk / compileSdk | 21 / 35 / 35 |
| ABI coverage | arm64-v8a, armeabi-v7a, x86, x86_64 |
| Multidex | 10 DEX files, ~76 MB of compiled code |
| Permissions | 47 (incl. BG location, contacts, calendar, accounts) |
| API base | `https://api.familywall.com` |
| Internal SDK | Jeronimo Fiz (`com.jeronimo.fiz.*`) |
| 3rd-party SDKs | 50+ (Firebase, GA, Segment, AppsFlyer, Adjust, LaunchDarkly, Engagement.io, Play Billing, Purchasely, ezvCard, ical4j, Jackson, Protobuf, Glide, ButterKnife) |
| Signing cert | `CN=Nicolas Frattaroli, O=FRATT Invest` (APKPure mirror — NOT `family & Co` original cert) |

## Hardcoded secrets to NOT reuse in our clone

| RE value | Treat as |
|---|---|
| `OAUTH_CLIENT_SECRET=dBs2Bwf3bmC98ETLN6LIl6N29GjXxh4mv7qvEkY7` | **ROTATED + moved server-side** — never put on device |
| `APPSFLYER_API_KEY=VBhqEM4KCaDdfZYV3KnkwK` | Generate new, store behind proxy |
| `LAUNCHDARKLY_SDK_KEY=mob-62a30a67-...` | Generate new (own tenant) |
| `SEGMENT_API_KEY=qtgJTuBFCf9KrQ3ug8EED7n9rZQXQdtJ` | Generate new |
| `PURCHASELY_API_KEY=e289b7a2-...` | Generate new |
| Adjust secret (in libsigner.so) | Detect + relocate + never include |

These are flagged for end-to-end replacement — see `docs/API_CONTRACT.md` for the migration plan.

For the full structured report see the canonical at `D:\Reverse\FamilyWall\RE_REPORT.md`.

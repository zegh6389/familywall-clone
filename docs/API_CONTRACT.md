# FamilyWall Clone — API Contract

> **Source of truth** (extracted 2026-07-20): BuildConfig.smali + com.familywall.backend.net.* + apksigner fingerprint of API endpoints present in `D:\Reverse\FamilyWall\jadx_out\sources\com\familywall\backend\`.

**Base URL**: `https://api.familywall.com`
**Auth scheme**: OAuth2 client-credentials (RE has both client_id + client_secret in client app — ❌ bad; we keep secret server-side only)
**Wire format**: JSON (Jackson on RE side → `json_serializable` on our side) + multipart/form-data for file uploads (`AndroidMultipartHttpClient` analogue)

## Authentication

**Token endpoint** (RE-implied):
```
POST https://api.familywall.com/oauth/token
Content-Type: application/x-www-form-urlencoded

grant_type=client_credentials
&client_id=<OAUTH_CLIENT_ID>
&client_secret=<OAUTH_CLIENT_SECRET>
```
Returns `{"access_token": "...", "token_type": "Bearer", "expires_in": 86400, "scope": "family"}`

**RE client_id**: `3170dae7-7732-4372-8876-da578a916482`
**RE client_secret (HARDCODED)**: `dBs2Bwf3bmC98ETLN6LIl6N29GjXxh4mv7qvEkY7` ⚠️

⚠️ Do NOT reuse the RE client_secret. In our clone, the mobile app never sees the secret; auth happens via our backend proxy.

## Internal partner framework

`com.jeronimo.fiz.*` is an internal SDK (Jeronimo Fiz) — not publicly documented. In the RE app:
- `IAccount` interface defines account shape (member ID, family ID, partner scope)
- `PartnerTypeEnum` enum values: presumably `FAMILY_WALL`, possibly others
- `ICodecService` binary encoding/decoding helper
- `FizRuntimeException` thrown by accounts flow

In our Flutter clone we'll skip Jeronimo Fiz and use a plain DTO mapping.

## Endpoints (inferred from RE behavioural patterns)

> ⚠️ These are **plausible** inferred routes — we have the network interceptor pattern, the cache key scheme, and the data shapes, but no captured traffic yet. Final endpoints must be confirmed by running the RE app with mitmproxy/Charles. For now, the contract here is enough to scaffold the mobile side.

### Auth
| Method | Path | Purpose |
|---|---|---|
| POST | `/oauth/token` | Client-credentials token |
| POST | `/oauth/user-token` | Exchange token for user-scoped token after sign-in |
| POST | `/account/register` | Account creation |
| POST | `/account/sign-in` | Sign-in |
| POST | `/account/refresh` | Token refresh |
| GET | `/account/me` | Get current account info |

### Family / Circle
| Method | Path | Purpose |
|---|---|---|
| GET | `/families` | List user's families (multi-family support) |
| POST | `/families` | Create a family |
| GET | `/families/{familyId}` | Family details |
| GET | `/families/{familyId}/members` | Member list |
| POST | `/families/{familyId}/members` | Invite member |
| DELETE | `/families/{familyId}/members/{memberId}` | Remove member |
| GET | `/families/{familyId}/places` | Saved places |
| POST | `/families/{familyId}/places` | Add place |

### Members
| Method | Path | Purpose |
|---|---|---|
| GET | `/members/{memberId}` | Member profile |
| PUT | `/members/{memberId}` | Edit profile |
| POST | `/members/{memberId}/photo` | Upload profile photo (multipart) |
| GET | `/members/{memberId}/location` | Last known location |
| POST | `/members/{memberId}/location` | Upload own location (batched) |
| GET | `/members/{memberId}/battery` | Phone battery level |
| POST | `/members/{memberId}/panic` | Trigger panic alert (SOS) |
| POST | `/members/{memberId}/checkin` | Check in at place |

### Chat / Wall
| Method | Path | Purpose |
|---|---|---|
| GET | `/families/{familyId}/threads` | List threads |
| POST | `/families/{familyId}/threads` | Create thread |
| GET | `/threads/{threadId}/messages` | List messages |
| POST | `/threads/{threadId}/messages` | Send message (or shout to wall) |
| POST | `/threads/{threadId}/messages/{msgId}/like` | Like |
| POST | `/threads/{threadId}/messages/{msgId}/comments` | Comment |

### Media
| Method | Path | Purpose |
|---|---|---|
| POST | `/media/upload` | Upload (multipart, replaces `AndroidMultipartHttpClient`) |
| GET | `/albums/{familyId}` | Family album |
| GET | `/albums/{familyId}/media` | List media |
| DELETE | `/media/{mediaId}` | Delete media |

### Events / Calendar
| Method | Path | Purpose |
|---|---|---|
| GET | `/families/{familyId}/events` | Events |
| POST | `/families/{familyId}/events` | Create event |
| PUT | `/events/{eventId}` | Edit event |
| DELETE | `/events/{eventId}` | Delete event |
| POST | `/events/import/ics` | Upload .ics file (calendar invite) |

### Reminders / Tasks / Timbetables / Birthdays / Budget / Meals
| Method | Path | Purpose |
|---|---|---|
| GET/POST/PUT/DELETE | `/families/{familyId}/reminders/...` | CRUD reminders |
| GET/POST/PUT/DELETE | `/families/{familyId}/tasks/...` | Tasks |
| GET/POST/PUT/DELETE | `/families/{familyId}/timetables/...` | Timetables (per member) |
| GET/POST/PUT/DELETE | `/families/{familyId}/birthdays/...` | Birthdays |
| GET/POST/PUT/DELETE | `/families/{familyId}/budget/...` | Budget categories, transactions, payment methods |
| GET/POST/PUT/DELETE | `/families/{familyId}/meal-plans/...` | Meal plans |

### Notifications
| Method | Path | Purpose |
|---|---|---|
| POST | `/devices/register` | Register FCM token |
| POST | `/devices/unregister` | Remove token |

## Cache strategy

`com.familywall.backend.cache.CacheResultLiveData` is bespoke — each request path has:
- A `cacheKey`
- A TTL window
- A "writeback" job that uploads local edits when network returns

Drift equivalent: we'll model this with a `cached_responses` table keyed on `(endpoint, familyId, memberId)` with `cached_at` + `expires_at` columns + a sync queue.

## Wire format example (Member)

```json
{
  "id": "f3a09481-...",
  "firstName": "Alex",
  "lastName": "Johnson",
  "avatar": "https://cdn.familywall.com/m/...",
  "familyId": "f3a09481-...",
  "partnerScope": "FAMILY_WALL",
  "phoneNumber": "+1...",
  "batteryLevel": 84,
  "batteryCharging": false,
  "location": {
    "lat": 43.6532,
    "lon": -79.3832,
    "accuracy": 12.5,
    "timestamp": "2026-07-20T18:30:00Z",
    "placeId": "...",
    "address": "Toronto, ON"
  },
  "placeId": "..."
}
```

## Things we DO need to confirm in next RE pass

1. Exact endpoint paths and HTTP shapes
2. Field naming conventions (snake_case vs camelCase)
3. Pagination (cursor vs offset/limit)
4. WebSocket endpoints for real-time location/chat
5. Media CDN host (likely separate from api.familywall.com)
6. ICS import endpoint exact path
7. Whether the OAuth flow has PKCE or just client_credentials

→ Run mitmproxy against a rooted device running the RE APK with `network_security_config.xml` allowing user-installed CA certs. Captured traffic will populate the gaps above.

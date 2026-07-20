# Icons8 Integration — FamilyWall Clone

> Icons are downloaded from Icons8 via the `mcp__icons8mcp__search_icons` tool. Each goes into `assets/icons/` and is registered in `pubspec.yaml`. Then `flutter pub run flutter_launcher_icons` regenerates all platform launcher icon variants.

## Tool: `mcp__icons8mcp__*`

Already wired to Hermes — see server config. Use these from the chat session:

```
mcp__icons8mcp__search_icons  → discover by term ("family", "calendar", "shield")
mcp__icons8mcp__get_icon_svg  → SVG URL (preferred)
mcp__icons8mcp__get_icon_png_url → PNG fallback at requested size
mcp__icons8mcp__list_platforms → see all styles ("ios", "fluent", "color", etc.)
```

## Icon strategy

1. **Search by conceptual meaning**, not by literal word:
   - "communication" → chat bubble icons
   - "family" → multi-person, parent-child
   - "shield" → safety/panic icons
   - "location" → pin/map markers
   - "calendar" → event icons
   - "money" → budget icons
   - "utensils" → meal planner
   - "graduation-cap" → timetables
   - "cake" → birthdays
   - "task" → todo
   - "alarm" → reminders

2. **Use the icon8 `iOS` style** for the main app icon (matches the iOS FamilyWall look).

3. **Use the icon8 `Color` style** for in-app icons (color-coded section pills).

4. **Save SVG** (preferred) to `assets/icons/<name>.svg`. Use `flutter_svg` to load:
   ```dart
   SvgPicture.asset('assets/icons/family.svg')
   ```

5. **Save PNG** for the launcher icons (Android adaptive, iOS).

## Naming convention

- `assets/icons/<screen>_<element>.svg` (snake_case)
- Examples:
  - `home_dashboard.svg`
  - `wall_chat_bubble.svg`
  - `family_member_avatar.svg`
  - `safety_panic_button.svg`
  - `map_location_pin.svg`

## Registration

In `pubspec.yaml`:
```yaml
flutter:
  assets:
    - assets/icons/
```

For the launcher icon (across all platform sizes), place a 1024×1024 PNG at `assets/icons/app-icon.png`, then run:
```bash
flutter pub run flutter_launcher_icons
```
The flutter_launcher_icons config block in `pubspec.yaml` handles Android + iOS + web.

## First-batch icon wishlist (parity with RE)

These map to bottom-nav tabs + section pills:

| Use | Search term | Style | Notes |
|---|---|---|---|
| Tab — Home | `home` | ios | Tab 1 |
| Tab — Wall | `chat` | ios | Tab 2 |
| Tab — Safety | `shield` | ios | Tab 3 (added vs RE; reused family-wall pattern) |
| Tab — Family | `family` | ios | Tab 4 |
| Section pill — Chat | `chat` | color | Section in member sheet |
| Section pill — Places | `pin` | color | Section in member sheet |
| Section pill — Family | `people` | color | Section in member sheet |
| Section pill — Activity | `history` | color | Section in member sheet |
| Action — Route | `route` | ios | Inline action button |
| Action — Call | `phone` | ios | Inline action |
| Action — Message | `comment` | ios | Inline action |
| Action — Check In | `location-cross` | ios | Inline action |
| Panic | `sos` | color | Big red button |
| Drag handle | (use —, none) | — | Render-only |
| Battery pill | `battery-3` | ios | Color coded |
| Status — online | `circle` | color (green) | Member status dot |
| Status — offline | `circle` | color (gray) | |
| Status — panic | `alert` | color (red) | |

## Where files go
```
app/
└── assets/
    └── icons/
        ├── home.svg
        ├── chat.svg
        ├── shield.svg
        ├── family.svg
        ├── route.svg
        ├── phone.svg
        ├── comment.svg
        ├── location-cross.svg
        ├── sos.svg
        ├── battery-3.svg
        ├── online.svg
        ├── offline.svg
        ├── alert.svg
        └── app-icon.png    # 1024×1024, source for flutter_launcher_icons
```

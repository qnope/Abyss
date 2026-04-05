# Terrain & Map Content Icons — Architecture

## Overview

Twelve hand-coded SVG icons provide the visual layer for the 20×20 game map. Four **terrain tiles** represent ground types; eight **map content overlays** represent points of interest placed on tiles. All use `viewBox="0 0 48 48"` (1:1 with Flutter tile size) and are rendered via `flutter_svg`.

## Terrain tiles

| Terrain | File | Color palette | Visual concept |
|---------|------|---------------|----------------|
| Reef | `reef.svg` | `#FF6E91` at 40% opacity | Coral formations with bioluminescent glow |
| Plain | `plain.svg` | `#42A5F5` at 40% opacity | Open sand with algae filaments and plankton |
| Rock | `rock.svg` | `#4A5568` (opaque) | Angular rock block with fissures and minerals |
| Fault | `fault.svg` | `#FF5252` lava, `#1A1A2E` base | Volcanic fissure with lava glow and particles |

Terrain tiles are **semi-transparent** (except rock) so the map background shows through. Visual variations (rotation, mirroring) are handled by Flutter transforms — no duplicate SVGs.

## Map content overlays

| Content | File | Color / Aura | Visual concept |
|---------|------|--------------|----------------|
| Resource bonus | `resource_bonus.svg` | `#FFD740` gold | Treasure chest with golden light beam |
| Ruins | `ruins.svg` | `#B388FF` purple | Broken arch with nacré glow and inscriptions |
| Monster (easy) | `monster_easy.svg` | `#69F0AE` green, 1 star | Small cave with green aura |
| Monster (medium) | `monster_medium.svg` | `#FFD740` orange, 2 stars | Medium cave with orange aura |
| Monster (hard) | `monster_hard.svg` | `#FF5252` red, 3 stars | Large jagged cave with tentacles |
| Player base | `player_base.svg` | `#00E5FF` cyan | Bioluminescent dome — brightest element on map |
| Faction (neutral) | `faction_neutral.svg` | `#42A5F5` blue | Subdued dome with handshake symbol |
| Faction (hostile) | `faction_hostile.svg` | `#FF5252` red | Red dome with defensive spikes |

Monster difficulty uses **double coding**: color (green / orange / red) **and** star count (1 / 2 / 3) for accessibility.

## File structure

```
assets/icons/terrain/
  ├── fault.svg
  ├── plain.svg
  ├── reef.svg
  └── rock.svg

assets/icons/map_content/
  ├── faction_hostile.svg
  ├── faction_neutral.svg
  ├── monster_easy.svg
  ├── monster_medium.svg
  ├── monster_hard.svg
  ├── player_base.svg
  ├── resource_bonus.svg
  └── ruins.svg
```

## Design decisions

1. **48×48 viewBox** — Smaller than the 64×64 used by resource/building/unit icons because terrain tiles are rendered at map-tile scale, not detail-panel scale.

2. **Same SVG conventions** — Gradients in `<defs>`, `<filter>` with `feGaussianBlur` + `feMerge` for bioluminescent glow, explicit filter regions (`x="-50%" y="-50%" width="200%" height="200%"`).

3. **ID prefixing** — All gradient and filter IDs are prefixed per asset (`reefGlow`, `easyGlow`, `baseGlow`, etc.) to prevent collisions when multiple SVGs coexist.

4. **flutter_svg compatibility** — No CSS, no `<use>`, no `<text>`, no external dependencies. Only basic SVG elements with inline attributes.

5. **File size budget** — Every asset stays under 5 KB to keep map rendering performant with 400 tiles on screen.

6. **Visual hierarchy** — Player base is the most luminous element; hostile faction next. Terrain tiles stay subdued so overlay content pops.

## Relationship to other icon sets

See `resource_icons.md`, `building_icons.md`, and `unit_icons.md`. Terrain icons follow the same bioluminescent style and SVG conventions, differing only in viewBox size and transparency approach.

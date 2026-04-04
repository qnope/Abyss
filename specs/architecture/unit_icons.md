# Unit Icons — Architecture

## Overview

Six hand-coded SVG icons represent the game's military units, stored in `assets/icons/units/`. Each unit has a unique silhouette and dominant color for instant recognition on the battlefield.

## Units

| Unit | File | Color palette | Visual concept |
|------|------|---------------|----------------|
| Scout (Eclaireur) | `scout.svg` | `#0D47A1` -> `#80D8FF` | Slim agile figure with blue visor and dorsal propulsor |
| Harpoonist (Harponneur) | `harpoonist.svg` | `#BF360C` -> `#FF6E40` | Imposing combatant with harpoon launcher and red targeting |
| Guardian (Gardien) | `guardian.svg` | `#607D8B` -> `#ECEFF1` | Massive coral-armored colossus with convex shield |
| Dome Breaker (Briseur) | `dome_breaker.svg` | `#E65100` -> `#FFAB40` | Stocky technician with orange generator and antennas |
| Siphoner (Siphonneur) | `siphoner.svg` | `#4A148C` -> `#B388FF` | Floating ghostly figure with violet bioluminescent circuits |
| Saboteur | `saboteur.svg` | `#1B5E20` -> `#69F0AE` | Crouched stealthy figure with green thermal goggles |

## File structure

```
assets/icons/units/
  ├── dome_breaker.svg
  ├── guardian.svg
  ├── harpoonist.svg
  ├── saboteur.svg
  ├── scout.svg
  └── siphoner.svg
```

## Design decisions

1. **Same SVG conventions as buildings** — Every icon uses `viewBox="0 0 64 64"`, gradients in `<defs>`, and a `<filter>` with `feGaussianBlur stdDeviation="3"` + `feMerge` for the bioluminescent glow effect.

2. **Unique color per unit** — Blue (scout), red/orange (harpoonist), grey-white (guardian), orange (dome breaker), violet (siphoner), green (saboteur). No two units share a dominant color.

3. **ID prefixing** — All gradient and filter IDs are prefixed with the unit name (`scout*`, `harpoonist*`, `guardian*`, `domeBreaker*`, `siphoner*`, `saboteur*`) to prevent collisions when multiple SVGs are loaded.

4. **flutter_svg compatibility** — No CSS, no `<use>`, no `<symbol>`. Only basic SVG elements with inline attributes.

5. **Silhouette-first design** — Each unit is recognizable by silhouette alone: slim/leaning (scout), wide shoulders (harpoonist), massive with shield (guardian), stocky with antennas (dome breaker), floating (siphoner), crouched (saboteur).

## Relationship to building icons

See `building_icons.md` for the building icon architecture. Unit icons follow the same SVG conventions (viewBox, gradient pattern, glow filter) to maintain visual coherence across the game UI.

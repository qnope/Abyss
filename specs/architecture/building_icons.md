# Building Icons — Architecture

## Overview

Five hand-coded SVG icons represent the game's buildings, stored in `assets/icons/buildings/`. Each building icon visually integrates elements from its associated resource icon to make the production relationship immediately clear.

## Buildings

| Building | File | Color palette | Visual concept |
|----------|------|---------------|----------------|
| Headquarters (QG) | `headquarters.svg` | `#7C4DFF` -> `#B388FF` | Domed command center with antenna and portholes |
| Algae Farm | `algae_farm.svg` | `#2E7D32` -> `#69F0AE` | Glass greenhouse dome with algae stems inside |
| Coral Mine | `coral_mine.svg` | `#C2185B` -> `#FF6E91` | Drilling rig with mechanical arm extracting coral |
| Ore Extractor | `ore_extractor.svg` | `#1565C0` -> `#42A5F5` | Heavy platform with drill, conveyor, and crystals |
| Solar Panel | `solar_panel.svg` | `#FF8F00` -> `#FFD740` | Angled panel arrays with energy sparks |

## File structure

```
assets/icons/buildings/
  ├── algae_farm.svg
  ├── coral_mine.svg
  ├── headquarters.svg
  ├── ore_extractor.svg
  └── solar_panel.svg
```

## Design decisions

1. **Consistent SVG structure** — Every icon follows the same template: `viewBox="0 0 64 64"`, a `<linearGradient>` (bottom-to-top), and a `<filter>` with `feGaussianBlur stdDeviation="3"` + `feMerge` for the bioluminescent glow.

2. **Color-matched to resources** — Each building uses the same color palette as its produced resource (e.g., algae farm uses algaeGreen, coral mine uses coralPink). This creates instant visual association.

3. **Resource elements embedded** — Building icons incorporate recognizable shapes from their resource icons (algae leaves, coral branches, ore crystals, lightning sparks) so the production link is clear without text.

4. **flutter_svg compatibility** — No CSS, no `<use>`, no complex `<clipPath>`. Only basic SVG elements (path, polygon, rect, circle, ellipse, line) with inline attributes.

5. **Filter region attributes** — All glow filters include explicit `x`/`y`/`width`/`height` (e.g., `-30% -30% 160% 160%`) to prevent clipping of the blur effect.

## Relationship to resource icons

See `resource_icons.md` for the resource icon architecture. Building icons follow the same conventions (viewBox, gradient direction, glow filter pattern) to maintain visual coherence across the game UI.

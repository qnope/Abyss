# Resource Icons — Architecture

## Overview

Five hand-coded SVG icons represent the game's resources, rendered in Flutter via `flutter_svg`. A single reusable widget maps resource types to their SVG assets.

## Resources

| Resource | File | Color palette | Shape |
|----------|------|---------------|-------|
| Algae (food) | `algae.svg` | `#2E7D32` → `#69F0AE` | Wavy seaweed leaves |
| Coral (construction) | `coral.svg` | `#C2185B` → `#FF6E91` | Branching coral arms |
| Ore (metal) | `ore.svg` | `#1565C0` → `#42A5F5` | Faceted hexagonal crystal |
| Energy | `energy.svg` | `#FF8F00` → `#FFD740` | Lightning bolt |
| Pearl (rare) | `pearl.svg` | `#B2EBF2` → `#FFFFFF` | Sphere with nacreous sheen |

## File structure

```
assets/icons/resources/
  ├── algae.svg
  ├── coral.svg
  ├── energy.svg
  ├── ore.svg
  └── pearl.svg

lib/presentation/widgets/
  └── resource_icon.dart    # ResourceType enum + ResourceIcon widget

test/presentation/widgets/
  └── resource_icon_test.dart
```

## Design decisions

1. **SVG format** — Vector icons scale cleanly from 24px (resource bar) to 64px (building screens). All use viewBox `0 0 64 64`.

2. **Bioluminescent style** — Each icon uses a `<linearGradient>` or `<radialGradient>` combined with a `<feGaussianBlur>` glow filter to match the deep-sea Abyss theme.

3. **Shape distinctness** — Icons are distinguishable by shape alone (not just color), aiding accessibility: organic curves (algae, coral), sharp geometry (ore), zigzag (energy), circle (pearl).

4. **ResourceType enum** — Lives in the presentation layer for now. Will move to the domain layer when the resource system is built.

5. **Asset path convention** — `assets/icons/resources/{type.name}.svg` — the widget derives paths from the enum name, so adding a resource means adding an enum value and an SVG file.

## Dependencies

- `flutter_svg: ^2.0.17` — SVG rendering in Flutter.

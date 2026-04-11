# Task 01 — Create descent_module.svg

## Summary

Create the SVG icon for the **Module de Descente** building — a technological portal/rift gateway that opens a path into the abyss. The icon must be 150+ lines, perfectly Y-axis symmetrical, and follow existing SVG conventions.

## Reference

- Existing convention: `assets/icons/buildings/laboratory.svg` (63 lines, `<defs>` with gradients + glow filter, `<g>` wrapper)
- Referenced at: `lib/presentation/extensions/building_type_extensions.dart:69`
- Rendered by: `lib/presentation/widgets/building/building_icon.dart` via `SvgPicture.asset()`

## Implementation Steps

### Step 1 — Defs section (gradients + filter)

Create file `assets/icons/buildings/descent_module.svg` with:

```xml
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">
  <defs>
    ...gradients and filter...
  </defs>
  <g filter="url(#dmGlow)">
    ...content...
  </g>
</svg>
```

Define these gradients (all IDs prefixed `dm`):

| ID | Purpose | Colors |
|---|---|---|
| `dmFrameGrad` | Metallic frame | `#1A237E` (dark) to `#448AFF` (biolumBlue) |
| `dmRiftGrad` | Rift energy core | `#448AFF` (blue) to `#69F0AE` (green bioluminescent) |
| `dmBaseGrad` | Platform base | `#0D1B3E` (dark) to `#1A237E` (deep blue) |
| `dmEnergyGrad` | Inner rift undulation | `#00E676` (green) to `#448AFF` (blue) |
| `dmGlowGrad` | Outer glow aura | `#448AFF` at 0% to transparent at 100% |

Define glow filter:
```xml
<filter id="dmGlow" x="-30%" y="-30%" width="160%" height="160%">
  <feGaussianBlur in="SourceGraphic" stdDeviation="3" result="blur"/>
  <feMerge>
    <feMergeNode in="blur"/>
    <feMergeNode in="SourceGraphic"/>
  </feMerge>
</filter>
```

### Step 2 — Base platform

Standard base plate at bottom of icon (y ~48-54), consistent with other buildings:
- Main platform `<rect>` with `dmBaseGrad`
- Small tech details (conduit lines, indicator lights) on the base

### Step 3 — Technological frame / gateway arch

The main structure: a metallic arch/gateway surrounding the rift. Must be **perfectly symmetrical** on x=32.

- Two vertical support pillars (left at ~x=12, right at ~x=52, mirrored)
- An arch connecting them at the top (~y=8-12)
- Structural support braces (diagonal lines from pillars to base)
- Small tech details on pillars: bolts (circles r=1), indicator lights (circles with colored fill), conduit lines

### Step 4 — Rift/portal energy interior

The central energy rift between the frame pillars:
- Undulating energy lines using `<path>` with curves (Q or C bezier), filled with `dmRiftGrad`
- Glowing fissure pattern: 3-4 wavy vertical lines with varying opacity
- Central bright core: ellipse or circle with high opacity green accent
- Energy wisps radiating outward from the rift center

### Step 5 — Particle/spark effects (minimum 6)

Scattered luminous dots around and inside the portal:
- At least 3 blue particles (`#448AFF`, varying opacity 0.3-0.8)
- At least 3 green particles (`#69F0AE` or `#00E676`, varying opacity 0.3-0.7)
- Small circles (r=0.5 to r=1.5)
- Distributed around the portal opening, some outside the frame suggesting escaping energy

### Step 6 — Symmetry verification

Every element must be symmetrical around x=32. For each positioned element on the left, there must be a matching one on the right. Use `transform="scale(-1,1) translate(-64,0)"` or manually mirror coordinates.

## Acceptance Criteria

- [x] File at `assets/icons/buildings/descent_module.svg`
- [x] `viewBox="0 0 64 64"`
- [x] All gradient/filter IDs prefixed with `dm`
- [x] `feGaussianBlur` glow filter
- [x] Perfect Y-axis symmetry (center at x=32)
- [x] 150+ lines of SVG
- [x] Blue (`#448AFF`) frame with green (`#69F0AE`, `#00E676`) rift accents
- [x] At least 6 particle/spark elements
- [x] No `<style>` blocks, no external refs
- [x] Single `<svg>` root with `xmlns`

## Test Plan

- `flutter analyze` — no new warnings
- `flutter test` — no regressions (existing `building_icon_test.dart` should still pass)
- Manual: visually inspect at 24px and 64px scale

## Notes

- Existing icons are ~63 lines. This icon needs 150+, so significantly more detail is expected.
- The rift energy should feel organic/deep-sea despite the tech frame — use curved paths, not sharp geometry.
- All styling via XML attributes, never `<style>` blocks.

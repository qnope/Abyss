# Task 02 — Create pressure_capsule.svg

## Summary

Create the SVG icon for the **Capsule Pressurisee** building — a heavy, armored capsule built to withstand extreme deep-sea pressure, evoking hydrothermal vent environments. The icon must be 150+ lines, perfectly Y-axis symmetrical, and follow existing SVG conventions.

## Reference

- Existing convention: `assets/icons/buildings/laboratory.svg` (63 lines, `<defs>` with gradients + glow filter, `<g>` wrapper)
- Referenced at: `lib/presentation/extensions/building_type_extensions.dart:70`
- Rendered by: `lib/presentation/widgets/building/building_icon.dart` via `SvgPicture.asset()`

## Implementation Steps

### Step 1 — Defs section (gradients + filter)

Create file `assets/icons/buildings/pressure_capsule.svg` with standard SVG structure.

Define these gradients (all IDs prefixed `pc`):

| ID | Purpose | Colors |
|---|---|---|
| `pcBodyGrad` | Main capsule body | `#004D5E` (dark cyan) to `#00E5FF` (biolumCyan) |
| `pcArmorGrad` | Armor plating | `#003844` (deep dark) to `#00838F` (mid cyan) |
| `pcBaseGrad` | Heavy-duty base | `#0D2B33` (very dark) to `#004D5E` |
| `pcHeatGrad` | Heat indicator accent | `#FF3D00` (deep orange) to `#FF6D00` (orange) |
| `pcVaporGrad` | Vapor wisps | `#00E5FF` at full to `#00E5FF` at 0% opacity |

Define glow filter:
```xml
<filter id="pcGlow" x="-30%" y="-30%" width="160%" height="160%">
  <feGaussianBlur in="SourceGraphic" stdDeviation="3" result="blur"/>
  <feMerge>
    <feMergeNode in="blur"/>
    <feMergeNode in="SourceGraphic"/>
  </feMerge>
</filter>
```

### Step 2 — Heavy-duty base / support structure

Reinforced base plate at bottom (~y=48-54):
- Wider/thicker than standard buildings to convey weight
- Support struts or legs extending from capsule to base
- Dark metallic fill with `pcBaseGrad`

### Step 3 — Main capsule body

Central oval/cylindrical capsule shape, symmetrical around x=32:
- Outer shell: large rounded rectangle or ellipse (~x=16 to x=48, y=12 to y=48)
- Visible armor plating: 2-3 segmented panels with subtle stroke lines
- Thick walls suggested by double outline or inner/outer shapes

### Step 4 — Pressure containment bands (horizontal rings)

3-4 horizontal pressure bands/rings segmenting the capsule:
- Horizontal `<rect>` or `<line>` elements spanning the capsule width
- Slightly different shade/gradient than the body panels
- Evenly spaced vertically across the capsule body

### Step 5 — Rivet/bolt details (minimum 4)

Small industrial rivets on the capsule surface:
- Small circles (r=1 to r=1.5) with metallic fill
- Positioned along pressure bands or at corners of armor plates
- At least 4 rivets, symmetrically placed (2 left, 2 right)

### Step 6 — Pressure gauges / indicator lights (minimum 2, warm colors)

Industrial gauges with warm accents:
- **Gauge 1**: Small circular pressure manometer (circle with inner arc/needle) — fill uses `pcHeatGrad` (`#FF6D00` / `#FF3D00`)
- **Gauge 2**: Indicator light or dial — warm-colored circle with glow
- Position on upper and/or mid sections of capsule body
- Symmetrically placed

### Step 7 — Vapor/steam particle effects (minimum 4)

Cyan vapor wisps and particles around the capsule:
- Small circles (r=0.5 to r=1.2) with `#00E5FF` fill at varying opacity (0.2-0.7)
- At least 4 particles distributed around the capsule exterior
- Some positioned above (rising steam), some to the sides
- Optionally: 1-2 small curved `<path>` wisps suggesting vapor trails

### Step 8 — Symmetry verification

Every element must be symmetrical around x=32. Mirror all left-side elements to the right.

## Acceptance Criteria

- [x] File at `assets/icons/buildings/pressure_capsule.svg`
- [x] `viewBox="0 0 64 64"`
- [x] All gradient/filter IDs prefixed with `pc`
- [x] `feGaussianBlur` glow filter
- [x] Perfect Y-axis symmetry (center at x=32)
- [x] 150+ lines of SVG
- [x] Cyan (`#00E5FF`) body with warm accents (`#FF6D00`, `#FF3D00`)
- [x] At least 4 rivet/bolt elements
- [x] At least 2 pressure gauge/indicator elements with warm fills
- [x] At least 4 vapor/particle elements
- [x] No `<style>` blocks, no external refs
- [x] Single `<svg>` root with `xmlns`

## Test Plan

- `flutter analyze` — no new warnings
- `flutter test` — no regressions (existing `building_icon_test.dart` should still pass)
- Manual: visually inspect at 24px and 64px scale

## Notes

- The capsule should feel **heavy and industrial** — thick lines, visible reinforcement, mechanical details.
- Warm accents (`#FF6D00`, `#FF3D00`) should be used sparingly for contrast — only on gauges/indicators, not the main body.
- Vapor effects should feel like steam rising from hydrothermal vents.
- All styling via XML attributes, never `<style>` blocks.

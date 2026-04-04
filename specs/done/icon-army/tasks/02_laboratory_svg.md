# Task 02 - Create Laboratory (Laboratoire) SVG Icon

## Summary

Create the SVG icon for the Laboratory building (`assets/icons/buildings/laboratory.svg`). The laboratory is a high-tech research facility with 3 tech trees (military, economy, exploration). The icon must use a **cyan/teal-green** palette distinct from the Algae Farm's organic green (#2E7D32/#69F0AE).

## Design Brief

- **Ambiance**: High-tech underwater research dome, scientific and futuristic
- **Color**: Teal/cyan-green gradient — suggested `#00695C` (dark teal) to `#64FFDA` (bright cyan-green)
- **Stroke color**: `#004D40` (deep teal for outlines)
- **Glow accent**: `#A7FFEB` (light cyan for science glow effects)
- **Key visual elements**:
  - Glass dome or transparent structure (similar concept to algae farm dome but more geometric/angular)
  - Scientific instruments: test tubes, holographic screens, or molecular structure
  - Cyan/teal light emanating from inside
  - Base platform (like all other buildings)
  - Optional: atom symbol, DNA helix, or microscope silhouette

## Implementation Steps

### Step 1 — SVG skeleton with defs

Create file `assets/icons/buildings/laboratory.svg` with:

```xml
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">
  <defs>
    <linearGradient id="labGrad" x1="0" y1="1" x2="0" y2="0">
      <stop offset="0%" stop-color="#00695C"/>
      <stop offset="100%" stop-color="#64FFDA"/>
    </linearGradient>
    <filter id="labGlow" x="-30%" y="-30%" width="160%" height="160%">
      <feGaussianBlur in="SourceGraphic" stdDeviation="3" result="blur"/>
      <feMerge>
        <feMergeNode in="blur"/>
        <feMergeNode in="SourceGraphic"/>
      </feMerge>
    </filter>
  </defs>
  <g filter="url(#labGlow)">
    <!-- content here -->
  </g>
</svg>
```

Conventions to follow (from existing icons):
- Gradient ID prefix: `lab`
- Filter ID prefix: `lab`
- Gradient direction: vertical bottom-to-top (`y1="1"` to `y2="0"`)
- Only basic SVG elements: `path`, `polygon`, `rect`, `circle`, `ellipse`, `line`, `polyline`
- No CSS, no `<use>`, no `<text>`

### Step 2 — Draw the base platform

Add a platform at the bottom (y ~48-55 range):
- Metal/structural base, consistent with other buildings
- Can use dark teal tones or neutral gray

### Step 3 — Draw the glass dome structure

Central dome:
- Rounded/hemispherical glass dome (use `path` with curves, similar to HQ dome but wider/flatter)
- Semi-transparent fill: `#64FFDA` with `fill-opacity="0.15"` (like algae farm glass)
- Visible frame/struts on the dome (lines for structural ribs)
- Stroke: `#64FFDA` with `stroke-opacity="0.6"`

### Step 4 — Add scientific instruments inside the dome

2-3 visible instruments behind the glass:
- **Test tubes/flasks**: Simple triangular or cylindrical shapes with colored liquid
- **Holographic screen**: Small rectangle with glow, angled
- Use `url(#labGrad)` for instrument fills

### Step 5 — Add science glow effects

- Glowing particles or light dots inside dome (`#A7FFEB`, small circles, various opacities)
- Optional: small orbiting dots suggesting atoms (2-3 circles on an elliptical path)

### Step 6 — Add distinctive tech details

Choose 1-2 of:
- Antenna or satellite dish on top of dome
- Small molecular/atom symbol floating above
- Equipment/pipes on the sides
- Data readout panel on the base

### Step 7 — Verify

- viewBox is `0 0 64 64`
- All elements inside the `<g filter="...">` group
- File saved at `assets/icons/buildings/laboratory.svg`
- No CSS, no `<use>`, no `<text>`
- Icon readable at 20-24px (not too many tiny details)

## Dependencies

- None (can be done independently, parallel with Task 01)
- Reference: existing icons in `assets/icons/buildings/` for style consistency

## Test Plan

- **File**: `assets/icons/buildings/laboratory.svg`
- **Structural validation**: SVG has `viewBox="0 0 64 64"`, contains `<defs>` with gradient + filter, single `<g>` with filter
- **Color check**: Uses teal/cyan-green palette (#00695C/#64FFDA range), clearly distinct from Algae Farm green (#2E7D32/#69F0AE)
- **flutter_svg compatibility**: No CSS, no `<use>`, no `<text>`, only basic SVG elements
- **Readability**: Icon recognizable as a scientific/research building at small sizes

## Notes

- The Algae Farm uses `#2E7D32 → #69F0AE` (organic warm green). The laboratory must be visibly more **teal/cyan** to differentiate. Using `#00695C → #64FFDA` shifts toward a cooler, more technological cyan-green.
- The dome shape may resemble the algae farm's dome, but the content inside (instruments vs plants) and color (teal vs green) will clearly differentiate them.
- Keep the design relatively simple (aim for ~40-70 lines of SVG content) to match the complexity of existing icons.

# Task 01 - Create Barracks (Caserne) SVG Icon

## Summary

Create the SVG icon for the Barracks building (`assets/icons/buildings/barracks.svg`). The barracks is a military bunker where human units (scout, soldier, engineer) are recruited. The icon must use an **orange/amber** palette distinct from the Solar Panel's yellow (#FF8F00/#FFD740).

## Design Brief

- **Ambiance**: Fortified underwater military bunker
- **Color**: Orange/amber gradient — suggested `#E65100` (dark burnt orange) to `#FFB74D` (light amber)
- **Stroke color**: `#BF360C` (deep orange-brown for outlines)
- **Glow accent**: `#FFCC80` (warm amber for porthole glow and highlights)
- **Key visual elements**:
  - Fortified structure with thick walls (rectangular, heavy, armored feel)
  - Crenellations or arrow slits (meurtieres) evoking defense
  - Luminous portholes (2-3, consistent with HQ style: dark fill + bright stroke + inner glow circle)
  - Base platform (like all other buildings)
  - Optional: small shield or crossed weapons emblem on facade

## Implementation Steps

### Step 1 — SVG skeleton with defs

Create file `assets/icons/buildings/barracks.svg` with:

```xml
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">
  <defs>
    <linearGradient id="barracksGrad" x1="0" y1="1" x2="0" y2="0">
      <stop offset="0%" stop-color="#E65100"/>
      <stop offset="100%" stop-color="#FFB74D"/>
    </linearGradient>
    <filter id="barracksGlow" x="-30%" y="-30%" width="160%" height="160%">
      <feGaussianBlur in="SourceGraphic" stdDeviation="3" result="blur"/>
      <feMerge>
        <feMergeNode in="blur"/>
        <feMergeNode in="SourceGraphic"/>
      </feMerge>
    </filter>
  </defs>
  <g filter="url(#barracksGlow)">
    <!-- content here -->
  </g>
</svg>
```

Conventions to follow (from existing icons):
- Gradient ID prefix: `barracks`
- Filter ID prefix: `barracks`
- Gradient direction: vertical bottom-to-top (`y1="1"` to `y2="0"`)
- Only basic SVG elements: `path`, `polygon`, `rect`, `circle`, `ellipse`, `line`, `polyline`
- No CSS, no `<use>`, no `<text>`

### Step 2 — Draw the base platform

Add a platform at the bottom (y ~48-55 range), matching the style from HQ:
- Two-layer polygon platform (top plate + shadow plate)
- Gray/metal tones for the base (`#9E9E9E`/`#616161` or `#546E7A`/`#37474F`)

### Step 3 — Draw the main bunker structure

Central fortified structure:
- Thick rectangular body (wider than tall, heavy/squat feel unlike the tall HQ dome)
- Use `url(#barracksGrad)` fill with `#BF360C` stroke
- Slight rounded corners (`rx="1"`) for consistency

### Step 4 — Add crenellations / arrow slits

Top of bunker:
- 3-4 rectangular crenellations (merlons) along the top edge
- Or arrow slits (thin vertical rectangles) on the facade, filled dark with bright stroke

### Step 5 — Add portholes

2-3 luminous portholes on the facade, following HQ pattern:
- Outer circle: dark fill (`#3E1400`), bright stroke (`#FFCC80`), stroke-width 0.6
- Inner circle: amber fill (`#FFB74D`), opacity 0.7

### Step 6 — Add distinctive military details

Choose 1-2 of:
- Small crossed weapons/shield emblem above the door
- Reinforcement plates/rivets on walls
- Armored door at center base
- Small watchtower or periscope on top

### Step 7 — Verify

- viewBox is `0 0 64 64`
- All elements inside the `<g filter="...">` group
- File saved at `assets/icons/buildings/barracks.svg`
- No CSS, no `<use>`, no `<text>`
- Icon readable at 20-24px (not too many tiny details)

## Dependencies

- None (can be done independently)
- Reference: existing icons in `assets/icons/buildings/` for style consistency

## Test Plan

- **File**: `assets/icons/buildings/barracks.svg`
- **Structural validation**: SVG has `viewBox="0 0 64 64"`, contains `<defs>` with gradient + filter, single `<g>` with filter
- **Color check**: Uses orange/amber palette (#E65100/#FFB74D range), clearly distinct from Solar Panel yellow (#FF8F00/#FFD740)
- **flutter_svg compatibility**: No CSS, no `<use>`, no `<text>`, only basic SVG elements
- **Readability**: Icon recognizable as a military/fortified building at small sizes

## Notes

- The Solar Panel uses `#FF8F00 → #FFD740` (yellow-amber). The barracks must be visibly more **orange/burnt** to differentiate. Using `#E65100 → #FFB74D` shifts toward burnt orange while keeping an amber warmth.
- Keep the design relatively simple (aim for ~40-70 lines of SVG content) to match the complexity of existing icons.

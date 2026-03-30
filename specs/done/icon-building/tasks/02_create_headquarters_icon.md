# Task 02 - Create headquarters (QG) icon

## Summary
Create the SVG icon for the Quartier General (headquarters) building with violet bioluminescent theme.

## Implementation Steps

1. Create `assets/icons/buildings/headquarters.svg`
2. SVG structure:
   - `viewBox="0 0 64 64"`
   - `<linearGradient id="hqGrad">` from `#7C4DFF` (dark violet) to `#B388FF` (bright violet)
   - `<filter id="hqGlow">` with `feGaussianBlur stdDeviation="3"` + `feMerge`
   - `<g filter="url(#hqGlow)">` wrapping all elements
3. Visual elements to draw:
   - **Central dome**: large rounded dome shape as the main structure (path/ellipse)
   - **Base platform**: horizontal metallic base/foundation
   - **Antenna/tower**: central vertical antenna or command tower on top of the dome
   - **Hublots (portholes)**: 2-3 small luminous circles on the dome to suggest windows
   - **Side structures**: small flanking towers or extensions
   - **Luminous glow**: additional subtle radial gradient or circles for the violet emanation effect
4. Keep all SVG features compatible with flutter_svg (no CSS, no `<use>`, no `<clipPath>` with complex shapes)

## Dependencies
- Task 01 (directory must exist)

## Test Plan
- Visual inspection: icon must read as a "command center" at 24x24 and 64x64
- Verify SVG is valid XML
- Colors must match biolumPurple theme (`#B388FF` / `#7C4DFF`)

## Notes
- This is the most "prestigious" building - it should feel powerful and central
- Use the same gradient direction (bottom-to-top: y1="1" y2="0") as existing resource icons
- Refer to `assets/icons/resources/ore.svg` for polygon/geometric structure inspiration

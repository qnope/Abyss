# Task 03 - Create algae farm icon

## Summary
Create the SVG icon for the Ferme d'algues (algae farm) building with green theme, integrating algae resource elements.

## Implementation Steps

1. Create `assets/icons/buildings/algae_farm.svg`
2. SVG structure:
   - `viewBox="0 0 64 64"`
   - `<linearGradient id="algaeFarmGrad">` from `#2E7D32` (dark green) to `#69F0AE` (bright green)
   - `<filter id="algaeFarmGlow">` with `feGaussianBlur stdDeviation="3"` + `feMerge`
   - `<g filter="url(#algaeFarmGlow)">` wrapping all elements
3. Visual elements to draw:
   - **Glass dome/greenhouse**: transparent-looking dome or rectangular greenhouse structure (use lighter stroke or semi-transparent fill)
   - **Metallic base/frame**: structural frame of the greenhouse in darker green
   - **Algae plants inside**: 2-3 wavy algae stems/leaves growing inside the dome (reuse style from `assets/icons/resources/algae.svg` - curved paths)
   - **Light fixtures**: small circles or lines suggesting grow lights inside the dome
   - **Pipes/tubes**: output pipes on the side of the structure
4. Keep all SVG features compatible with flutter_svg

## Dependencies
- Task 01 (directory must exist)

## Test Plan
- Visual inspection: icon must clearly read as "greenhouse growing algae"
- The algae elements inside should be recognizable as the same algae from the resource icon
- Colors must match algaeGreen theme (`#69F0AE` / `#2E7D32`)

## Notes
- Refer to `assets/icons/resources/algae.svg` for the algae leaf/stem path style
- The dome should feel like a bio-containment structure, high-tech but nurturing

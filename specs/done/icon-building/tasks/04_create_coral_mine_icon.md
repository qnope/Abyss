# Task 04 - Create coral mine icon

## Summary
Create the SVG icon for the Mine de corail (coral mine) building with pink theme, integrating coral resource elements.

## Implementation Steps

1. Create `assets/icons/buildings/coral_mine.svg`
2. SVG structure:
   - `viewBox="0 0 64 64"`
   - `<linearGradient id="coralMineGrad">` from `#C2185B` (dark pink) to `#FF6E91` (bright pink)
   - `<filter id="coralMineGlow">` with `feGaussianBlur stdDeviation="3"` + `feMerge`
   - `<g filter="url(#coralMineGlow)">` wrapping all elements
3. Visual elements to draw:
   - **Drilling/extraction structure**: central mechanical structure with drill or excavator arm
   - **Mechanical arm**: articulated arm reaching down or to the side
   - **Coral fragments**: branching coral pieces (reuse branching path style from `assets/icons/resources/coral.svg`) being extracted or visible near the machine
   - **Platform/base**: industrial platform anchored to the seabed
   - **Detail elements**: gears, bolts, or mechanical joints to reinforce the industrial look
4. Keep all SVG features compatible with flutter_svg

## Dependencies
- Task 01 (directory must exist)

## Test Plan
- Visual inspection: icon must clearly read as "machine extracting coral"
- Coral elements should be recognizable as the same coral from the resource icon
- Colors must match coralPink theme (`#FF6E91` / `#C2185B`)

## Notes
- Refer to `assets/icons/resources/coral.svg` for the branching coral path style
- The contrast between organic coral and mechanical extraction is key to readability

# Task 06 - Create solar panel icon

## Summary
Create the SVG icon for the Panneau solaire (solar panel) building with yellow theme, integrating energy resource elements.

## Implementation Steps

1. Create `assets/icons/buildings/solar_panel.svg`
2. SVG structure:
   - `viewBox="0 0 64 64"`
   - `<linearGradient id="solarGrad">` from `#FF8F00` (dark yellow/amber) to `#FFD740` (bright yellow)
   - `<filter id="solarGlow">` with `feGaussianBlur stdDeviation="3"` + `feMerge`
   - `<g filter="url(#solarGlow)">` wrapping all elements
3. Visual elements to draw:
   - **Solar panels**: 2-3 angled rectangular panels deployed like satellite dish arrays
   - **Support structure**: central mast/pillar holding the panels, with articulation joints
   - **Energy effects**: small lightning bolt shapes or spark lines (reuse zigzag style from `assets/icons/resources/energy.svg`) emanating from the panels
   - **Cables**: lines going down from the panels to a base unit
   - **Light rays**: short radiating lines above/around the panels suggesting light capture
4. Keep all SVG features compatible with flutter_svg

## Dependencies
- Task 01 (directory must exist)

## Test Plan
- Visual inspection: icon must clearly read as "solar panels producing energy"
- Energy spark elements should be recognizable as related to the energy resource icon
- Colors must match energyYellow theme (`#FFD740` / `#FF8F00`)

## Notes
- Refer to `assets/icons/resources/energy.svg` for the lightning bolt / spark style
- These panels are underwater solar collectors - they should feel futuristic, not like rooftop panels
- Remember: per ABYSS.md, solar panels only work at level 1 (surface) - but this doesn't affect the icon design

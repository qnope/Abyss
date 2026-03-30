# Task 05 - Create ore extractor icon

## Summary
Create the SVG icon for the Extracteur de minerai (ore extractor) building with blue theme, integrating ore/crystal resource elements.

## Implementation Steps

1. Create `assets/icons/buildings/ore_extractor.svg`
2. SVG structure:
   - `viewBox="0 0 64 64"`
   - `<linearGradient id="oreExtGrad">` from `#1565C0` (dark blue) to `#42A5F5` (bright blue)
   - `<filter id="oreExtGlow">` with `feGaussianBlur stdDeviation="3"` + `feMerge`
   - `<g filter="url(#oreExtGlow)">` wrapping all elements
3. Visual elements to draw:
   - **Heavy extraction platform**: large industrial structure, drilling platform or refinery shape
   - **Drill/conveyor**: vertical drill going down or conveyor belt mechanism
   - **Crystals/ore blocks**: faceted blue crystals (reuse hexagonal polygon style from `assets/icons/resources/ore.svg`) being mined or stacked near the machine
   - **Structural supports**: legs or pillars supporting the platform
   - **Detail elements**: tubes, exhaust, mechanical components
4. Keep all SVG features compatible with flutter_svg

## Dependencies
- Task 01 (directory must exist)

## Test Plan
- Visual inspection: icon must clearly read as "machine mining blue crystals"
- Crystal elements should be recognizable as the same ore from the resource icon
- Colors must match oreBlue theme (`#42A5F5` / `#1565C0`)

## Notes
- Refer to `assets/icons/resources/ore.svg` for the faceted crystal polygon style
- This is the heaviest/most industrial building - should feel massive and powerful

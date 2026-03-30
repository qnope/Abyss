# Task 07 - Validate all building icons

## Summary
Verify all 5 SVG building icons are valid, render correctly in Flutter, and pass analysis.

## Implementation Steps

1. Verify all 5 SVG files exist in `assets/icons/buildings/`:
   - `headquarters.svg`
   - `algae_farm.svg`
   - `coral_mine.svg`
   - `ore_extractor.svg`
   - `solar_panel.svg`
2. Run `flutter analyze` to ensure no issues with asset registration
3. Run `flutter test` to ensure nothing is broken
4. Review each SVG for:
   - Valid XML structure
   - Correct viewBox `0 0 64 64`
   - Proper gradient definitions (linearGradient with correct colors)
   - Glow filter present (feGaussianBlur + feMerge)
   - No unsupported SVG features for flutter_svg (no CSS, no `<use>`, no complex clipPath)

## Dependencies
- Tasks 01-06 (all icons must be created)

## Test Plan
- `flutter analyze` passes with no errors
- `flutter test` passes with no errors
- Each SVG file is well-formed XML
- Visual inspection confirms readability at small sizes

## Notes
- flutter_svg does not support all SVG features - avoid: CSS styles, `<use>` references, complex filters beyond gaussian blur, `<foreignObject>`
- If any icon fails to render, simplify the SVG structure while keeping the visual identity

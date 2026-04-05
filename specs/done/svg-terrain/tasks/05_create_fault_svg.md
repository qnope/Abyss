# Task 05 — Create fault.svg

## Summary

Create the abyssal fault terrain tile SVG at `assets/icons/terrain/fault.svg`. Most dramatic tile — opaque dark background with volcanic fissure, lava glow, and heat particles.

## Implementation Steps

1. Create file `assets/icons/terrain/fault.svg` with viewBox `0 0 48 48`
2. **Defs section**:
   - Linear gradient `faultLavaGrad` along fissure: center `#FF4500` → `#FF5252` → edges `#FF8A65`
   - Filter `faultGlow` combining `feGaussianBlur` (stdDeviation=3) + `feColorMatrix` for volcanic halo
   - Explicit filter region attributes: `x="-40%" y="-40%" width="180%" height="180%"`
3. **Background layer**: Rectangle 48x48, fill `#1A1A2E` at 100% opacity (fully opaque, darker than standard abyssBlack)
4. **Central fissure**: Irregular zigzag path from upper-third to lower-third (or diagonal). Width 3-6px, jagged asymmetric edges. Interior filled with `faultLavaGrad`
5. **Volcanic glow**: Path following fissure shape, filtered with `faultGlow`. Fill `#FF5252` at 40% opacity. Halo extends 4-6px beyond fissure edges
6. **Secondary cracks**: 4-6 thinner fissures radiating from main crack, stroke-width 0.3-0.5, color `#2A1A3E`, extending 5-10px
7. **Suspended particles**: 5-8 circles of varying sizes (r=0.5-1.5) above fissure. Near fissure: `#FF8A65` at 50% opacity. Far: `#FF5252` at 15% opacity
8. **Heat points**: 2-3 tiny circles (r=0.8-1) inside fissure at widest points, fill `#FFD740` at 70% opacity
9. **Basalt texture**: Subtle hexagonal/pentagonal shapes at left and right edges, stroke 0.3, fill `#1F1F35` at 30%

## Dependencies

- Task 01 (directory must exist)

## Test Plan

- File exists at `assets/icons/terrain/fault.svg`
- Valid SVG 1.1 with viewBox `0 0 48 48`
- No text, no external fonts/images
- File size < 5 KB
- Fully opaque background
- Uses: `#1A1A2E`, `#FF4500`, `#FF5252`, `#FF8A65`, `#2A1A3E`, `#FFD740`, `#1F1F35`

## Design Notes

- Most visually dramatic tile — lava contrast against deep black is striking
- The `feColorMatrix` filter enhances the red/orange glow intensity
- Filter region must be generous (`-40%`, `180%`) because the glow extends well beyond the source shape
- For `flutter_svg` compatibility: no CSS, no `<use>`, only basic SVG elements with inline attributes
- Test that `feColorMatrix` renders correctly in flutter_svg — if not, fall back to layered `feGaussianBlur` only

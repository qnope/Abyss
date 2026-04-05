# Task 04 — Create rock.svg

## Summary

Create the rock block terrain tile SVG at `assets/icons/terrain/rock.svg`. Fully opaque, dark, dense and mineral. Impassable wall.

## Implementation Steps

1. Create file `assets/icons/terrain/rock.svg` with viewBox `0 0 48 48`
2. **Defs section**: Define a linear gradient `rockMainGrad` diagonal (top-left → bottom-right) from `#5A6678` to `#3A4558`
3. **Background layer**: Rectangle 48x48, fill `#4A5568` at 100% opacity (fully opaque — no transparency)
4. **Main rock mass**: Irregular polygon with 8-12 vertices, occupying 80-90% of tile. Fill with `rockMainGrad`. Conveys a massive angular block
5. **Fissures**: 3-5 broken zigzag paths across rock surface. Stroke-width 0.5-0.8, color `#2D3748`. One main fissure from upper-left quarter to lower-right third, with shorter secondary fissures branching off
6. **Mineral reflections**: 2-3 small ellipses (2-3px) on upper faces, fill `#6B7C8F` at 60% opacity
7. **Sediment at base**: Band of 4-6px at bottom edge with small angular triangles (1-2px) in `#3A4558`
8. **Micro-organisms**: 1-2 circles (r=1-1.5) on rock surface, `#5A6678` at 50% opacity
9. **Perimeter shadow**: Subtle inner border 1-2px using `#2D3748` at 40% opacity for depth effect

## Dependencies

- Task 01 (directory must exist)

## Test Plan

- File exists at `assets/icons/terrain/rock.svg`
- Valid SVG 1.1 with viewBox `0 0 48 48`
- No text, no external fonts/images
- File size < 5 KB
- Fully opaque (no background transparency)
- Uses only: `#4A5568`, `#5A6678`, `#3A4558`, `#2D3748`, `#6B7C8F`

## Design Notes

- **Fully opaque** — rock blocks vision completely, unlike semi-transparent reef/plain
- No glow filter needed — rock is inert, mineral, no bioluminescence
- The inner shadow border creates a sense of the rock being "embedded" in the grid
- For `flutter_svg` compatibility: no CSS, no `<use>`, only basic SVG elements

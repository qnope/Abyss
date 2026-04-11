# Task 1: SVG Scaffold and Defs

## Summary

Create the SVG file with the root element, all `<defs>` (gradients and filters), and the background/seabed base layer. This establishes the foundation every subsequent task builds on.

## Implementation Steps

1. **Create file** `assets/icons/terrain/volcanic_kernel.svg`.
2. **Root element**: `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">`.
3. **Define gradients** inside `<defs>`:
   - `vkRockGrad` — `linearGradient` from `#1A1A1A` to `#3E2723` (dark rock body, bottom-to-top).
   - `vkLavaGrad` — `linearGradient` from `#FF3D00` to `#FF9100` (incandescent lava, bottom-to-top).
   - `vkCraterGlow` — `radialGradient` bright center `#FFAB00` fading to `#FF6D00` at 60% then transparent at 100%.
   - `vkPlumeGrad` — `linearGradient` from `#00E5FF` (opaque) to `#00BCD4` (transparent) for hydrothermal plumes.
   - `vkEmberGrad` — `radialGradient` from `#FFAB00` center to `#FF6D00` edge, for ember dots.
   - `vkSeabedGrad` — `linearGradient` from `#2D2D2D` to `#1B1B1B` (ocean floor).
4. **Define glow filter** `vkGlow` — match the project convention seen in `descent_module.svg`:
   ```xml
   <filter id="vkGlow" x="-30%" y="-30%" width="160%" height="160%">
     <feGaussianBlur in="SourceGraphic" stdDeviation="2" result="blur"/>
     <feMerge>
       <feMergeNode in="blur"/>
       <feMergeNode in="SourceGraphic"/>
     </feMerge>
   </filter>
   ```
5. **Seabed base layer** (bottom of the scene):
   - A rough, uneven ocean floor using a `<path>` with small bumps across the bottom ~12px of the viewBox, filled with `url(#vkSeabedGrad)`.
   - 3-4 scattered small rock shapes (`<ellipse>` or `<path>`) on the seabed for debris.

## Dependencies

- None (first task).

## Test Plan

- File exists at `assets/icons/terrain/volcanic_kernel.svg`.
- Valid XML: opening `<svg>` tag with correct `xmlns` and `viewBox="0 0 64 64"`.
- All gradient/filter IDs start with `vk`.
- No `<style>` blocks — all styling via attributes.
- No external references or embedded images.

## Notes

- Use attribute-only styling (no `<style>` blocks) per SPEC.
- The `stdDeviation` for the glow filter can be `2` (slightly tighter than the `3` used in `descent_module.svg`) since the volcanic details are denser and need sharper edges.
- Leave the main `<g>` group open for subsequent tasks to add layers inside.

# Volcanic Kernel SVG Icon — Feature Specification

## 1. Feature Overview

Create a highly detailed SVG icon representing an underwater volcanic kernel for the terrain tile system. The icon must immediately read as "volcano" — a submarine volcanic vent with an open crater, lava flows down its flanks, and rising hydrothermal bubbles/smoke in the surrounding water.

The file is placed in `assets/icons/terrain/volcanic_kernel.svg` alongside the existing `plain.svg` terrain icon.

### Design principles

- **150+ lines** of SVG — extremely detailed with rich layering.
- **Asymmetric composition** — organic, natural feel befitting a volcanic formation (no forced vertical symmetry).
- **Underwater context** — the volcano sits on the ocean floor; smoke becomes hydrothermal plumes, ash becomes suspended particles, and bubbles rise through water.
- **Dual palette** — incandescent reds/oranges for the lava/magma core, contrasted with cyan hydrothermal vapor accents to anchor it in the deep-sea theme.

---

## 2. User Stories

### US-1: Volcanic terrain icon

**As a** player exploring the fog-of-war map,
**I want to** see a distinctive volcanic terrain tile,
**So that** I immediately understand this cell is a dangerous, volcanic zone.

**Visual design:**

- **Silhouette**: Conical volcanic mound with irregular, craggy edges — not a perfect triangle. The peak has an open crater (depression/caldera).
- **Crater**: Visible opening at the top emitting a bright orange-red glow from within. The crater rim is darker, rocky.
- **Lava flows**: 2-3 rivulets of molten lava flowing asymmetrically down the volcano flanks. These are bright orange/red paths with glow effects.
- **Rocky flanks**: The volcano body is built from layered dark rock with subtle texture (cracks, ridges, shadow lines). Multiple shades of dark grey/brown.
- **Hydrothermal plumes**: Rising from the crater and side vents — cyan-tinted vapor trails curving upward through water. These connect the icon to the deep-sea theme.
- **Bubbles**: Scattered rising bubbles (small circles) in various sizes and opacities, suggesting underwater boiling near the heat source.
- **Particles/embers**: Small glowing orange dots near the crater and lava flows, suggesting ejected volcanic material suspended in water.
- **Ocean floor base**: A rough, uneven seabed at the bottom with scattered rocks/debris.
- **Side vent**: At least one secondary fissure on the flank emitting a small lava glow or vapor wisp (adds asymmetry and realism).

**Color palette:**

| Element | Colors |
|---------|--------|
| Lava / magma | `#FF3D00`, `#FF6D00`, `#FF9100` (red-orange incandescent) |
| Crater glow | `#FFAB00`, `#FF6D00` (bright amber-orange) |
| Rock body | `#1A1A1A`, `#2D2D2D`, `#3E2723`, `#4E342E` (dark greys/browns) |
| Hydrothermal vapor | `#00E5FF`, `#00BCD4` (cyan accents) |
| Bubbles | `#00E5FF` at low opacity |
| Embers/particles | `#FF6D00`, `#FFAB00` at varying opacities |
| Seabed | `#1B1B1B`, `#2D2D2D` |

**Acceptance criteria:**
- File: `assets/icons/terrain/volcanic_kernel.svg`
- ViewBox: `0 0 64 64`
- Uses `linearGradient` and `radialGradient` defs with id prefix `vk` (e.g., `vkLavaGrad`, `vkRockGrad`, `vkGlowGrad`).
- Uses `feGaussianBlur` glow filter consistent with other project icons.
- Intentionally **asymmetric** — lava flows, side vents, and bubbles placed organically.
- **150+ lines** of SVG code.
- At least 2 lava flow paths down the flanks.
- At least 1 side vent/fissure with glow.
- At least 6 bubble elements (varying size and opacity).
- At least 4 ember/particle elements near the crater.
- At least 2 hydrothermal plume paths (curved, rising).
- Crater glow uses radial gradient fading from bright center outward.
- Renders correctly at both 24px (map tile) and 64px (detail view) sizes.

---

## 3. Testing and Validation

### Visual consistency
- The SVG must render without errors via `flutter_svg`.
- It must look coherent alongside `plain.svg` in the terrain icon set.
- The volcanic theme must be instantly recognizable at 24px size (silhouette + orange glow readable even small).
- Greyscale filter (`ColorFilter.mode(..., BlendMode.srcIn)`) must apply correctly for unexplored/fog state.

### Technical checks
- `flutter analyze` passes with no new warnings.
- `flutter test` passes — no regressions.
- SVG loads correctly in terrain display widgets at default map tile size and enlarged detail size.

### File constraints
- Single `<svg>` root with `xmlns` and `viewBox="0 0 64 64"`.
- All gradient/filter IDs prefixed with `vk` to avoid collisions.
- No external references or embedded images.
- No `<style>` blocks — all styling via attributes.
- No animations — all effects are static (positioned particles, fixed paths).

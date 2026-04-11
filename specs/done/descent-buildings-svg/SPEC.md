# Descent Buildings SVG Icons — Feature Specification

## 1. Feature Overview

Create two highly detailed SVG icons for the descent buildings that are currently missing from the asset pipeline:

- **Module de Descente** (`descent_module.svg`) — portail/rift energetique
- **Capsule Pressurisee** (`pressure_capsule.svg`) — capsule blindee renforcee

Both files are already referenced in `building_type_extensions.dart` (lines 69-70) but do not exist yet. They must be placed in `assets/icons/buildings/` and follow the established SVG conventions.

### Design principles

- **150+ lines** of SVG each — significantly more detailed than the existing icons (~50-100 lines).
- **Perfect vertical symmetry** on the Y axis for a clean, polished look.
- **Static particle/spark effects** — luminous points suggesting energy in motion (positioned, not animated).
- **Visual cues** linking each icon to its target environment (faille abyssale / cheminee hydrothermale).

---

## 2. User Stories

### US-1: Module de Descente icon

**As a** player viewing the building list,
**I want to** see a distinctive portal/rift icon for the Module de Descente,
**So that** I immediately understand its purpose: opening a path into the abyss.

**Visual design:**

- **Style**: Technological frame enclosing an energy rift/portal.
- **Theme color**: biolumBlue (`#448AFF`) for the structural frame.
- **Rift energy**: Blue base with **green bioluminescent accents** — suggesting organic deep-sea energy.
- **Frame**: Metallic/tech arch or gateway surrounding the rift, with structural supports.
- **Rift interior**: Undulating energy lines, glowing fissure patterns evoking an abyssal rift.
- **Particles**: Scattered luminous dots (blue and green) around the portal suggesting escaping energy.
- **Base**: Standard platform/base plate consistent with other building icons.
- **Indicators**: Small tech details on the frame (lights, bolts, conduits).

**Acceptance criteria:**
- File: `assets/icons/buildings/descent_module.svg`
- ViewBox: `0 0 64 64`
- Uses `linearGradient` defs with id prefix `dm` (e.g., `dmGrad`, `dmRiftGrad`).
- Uses `feGaussianBlur` glow filter consistent with other icons.
- Perfectly symmetrical on the vertical axis.
- 150+ lines of SVG.
- Gradients use shades of `#448AFF` (biolumBlue) for structure, with green accents (`#69F0AE`, `#00E676`) for rift energy.
- At least 6 particle/spark elements (small circles with varying opacity).
- Renders correctly at both 24px (list) and 64px (detail view) sizes.

---

### US-2: Capsule Pressurisee icon

**As a** player viewing the building list,
**I want to** see a heavy, reinforced capsule icon for the Capsule Pressurisee,
**So that** I understand it is built to withstand extreme deep-sea pressure.

**Visual design:**

- **Style**: Thick, armored capsule with industrial reinforcements.
- **Theme color**: biolumCyan (`#00E5FF`) for the main body and ambient vapor.
- **Body**: Oval/cylindrical capsule shape with visible armor plating, rivets, and pressure seals.
- **Pressure joints**: Horizontal bands/rings segmenting the capsule, suggesting pressure containment.
- **Vapor effects**: Cyan vapor wisps/bubbles around the capsule evoking the hydrothermal environment.
- **Heat accents**: Orange/red (`#FF6D00`, `#FF3D00`) on pressure gauges and indicator lights, contrasting with the cyan body — evoking the heat of hydrothermal vents.
- **Gauges**: Small pressure manometers or dial indicators on the capsule surface.
- **Base**: Reinforced support structure / heavy-duty base plate.
- **Particles**: Small luminous dots (cyan) suggesting steam/vapor particles.

**Acceptance criteria:**
- File: `assets/icons/buildings/pressure_capsule.svg`
- ViewBox: `0 0 64 64`
- Uses `linearGradient` defs with id prefix `pc` (e.g., `pcGrad`, `pcArmorGrad`).
- Uses `feGaussianBlur` glow filter consistent with other icons.
- Perfectly symmetrical on the vertical axis.
- 150+ lines of SVG.
- Gradients use shades of `#00E5FF` (biolumCyan) for body and vapor, with warm accents (`#FF6D00`, `#FF3D00`) for heat indicators.
- At least 4 rivet/bolt detail elements.
- At least 2 pressure gauge/indicator elements with warm-colored fills.
- At least 4 vapor/particle elements (small circles or wisps with varying opacity).
- Renders correctly at both 24px (list) and 64px (detail view) sizes.

---

## 3. Testing and Validation

### Visual consistency
- Both SVGs must render without errors via `flutter_svg`.
- Both must look coherent alongside the 8 existing building icons at the same display size.
- Greyscale filter (`ColorFilter.mode(..., BlendMode.srcIn)`) must apply correctly for unbuilt state.

### Technical checks
- `flutter analyze` passes with no new warnings.
- `flutter test` passes — no regressions.
- SVGs load correctly in the `BuildingIcon` widget at default size (24px) and enlarged size (64px).

### File constraints
- Each SVG must be a single `<svg>` root with `xmlns` and `viewBox="0 0 64 64"`.
- All gradient/filter IDs must be unique and prefixed to avoid collisions with other SVGs.
- No external references or embedded images.
- No `<style>` blocks — all styling via attributes.

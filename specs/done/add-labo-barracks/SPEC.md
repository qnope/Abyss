# add-labo-barracks Feature Specification

## 1. Feature Overview

The game already has SVG assets for the **Laboratory** (laboratoire) and the **Barracks** (caserne), but they are not yet visible in-game. This feature integrates these two buildings into the existing building system so they appear in the building list alongside the other buildings (Headquarters, Algae Farm, Coral Mine, Ore Extractor, Solar Panel).

Both buildings are non-production buildings: they do not generate resources. Their specific gameplay roles (research for the laboratory, unit recruitment for the barracks) will be implemented in future features.

## 2. User Stories

### US-1: See the Laboratory in the building list
**As a** player,
**I want to** see the Laboratory in my building list,
**so that** I can know it exists and build it.

**Acceptance criteria:**
- The Laboratory appears in the building list with its SVG icon, name ("Laboratoire"), and description.
- When unbuilt (level 0), it is displayed with reduced opacity / greyscale like other unbuilt buildings.
- Tapping it opens the building detail sheet with its icon, name, level, and description.

### US-2: See the Barracks in the building list
**As a** player,
**I want to** see the Barracks in my building list,
**so that** I can know it exists and build it.

**Acceptance criteria:**
- The Barracks appears in the building list with its SVG icon, name ("Caserne"), and description.
- When unbuilt (level 0), it is displayed with reduced opacity / greyscale like other unbuilt buildings.
- Tapping it opens the building detail sheet with its icon, name, level, and description.

### US-3: Build and upgrade the Laboratory
**As a** player,
**I want to** build and upgrade the Laboratory,
**so that** I can progress in the game.

**Acceptance criteria:**
- The Laboratory requires **Headquarters level 2** to be built.
- The Laboratory has a **max level of 5**.
- Upgrade costs are similar in scale to existing production buildings (algae, coral, ore, energy).
- The upgrade section in the detail sheet shows costs and prerequisites correctly.

### US-4: Build and upgrade the Barracks
**As a** player,
**I want to** build and upgrade the Barracks,
**so that** I can progress in the game.

**Acceptance criteria:**
- The Barracks requires **Headquarters level 3** to be built.
- The Barracks has a **max level of 5**.
- Upgrade costs are similar in scale to existing production buildings.
- The upgrade section in the detail sheet shows costs and prerequisites correctly.

### US-5: New buildings are part of a new game
**As a** player,
**I want** the Laboratory and Barracks to be initialized at level 0 when I start a new game,
**so that** they are ready to be built.

**Acceptance criteria:**
- A new game includes Laboratory and Barracks at level 0 in the buildings map.
- Existing saved games are not broken by the addition of these buildings.

## 3. Testing and Validation

- **Unit tests** for the building cost calculator: verify that Laboratory and Barracks return correct costs, max levels, and prerequisites.
- **Unit tests** for the building type extensions: verify displayName, description, iconPath, and color for both new types.
- **Unit tests** for default buildings: verify that `defaultBuildings()` includes Laboratory and Barracks at level 0.
- **Widget tests** (if existing): verify both buildings render correctly in the building list.
- Run `flutter analyze` with zero issues.
- Run `flutter test` with all tests passing.

# Transition Improvements — Feature Specification

## 1. Feature Overview

Two improvements to the multi-level transition system:

1. **Passage markers on upper levels**: When the player explores a cell on level 2 (or 3) that corresponds to a transition base position on level 1 (or 2), that cell is displayed as empty with a glowing violet/magenta circle indicating the passage below. No content (monster, treasure, lair) can be generated at these positions.

2. **Level-scoped exploration highlighting**: Pending exploration markers (cyan borders) are only displayed on the level where the exploration was ordered, not across all levels.

---

## 2. User Stories

### US1 — Passage markers on upper levels

**As a** player exploring level 2 or 3,
**I want** to see a glowing violet circle on cells that correspond to a transition base (faille or cheminee) on the level below,
**So that** I can identify where the passages connect and understand the vertical geography.

**Acceptance criteria:**

- When level 2 is generated, positions of all failles from level 1 are reserved: no content (monster, treasure, lair, transition base) is placed at those coordinates on level 2.
- When level 3 is generated, positions of all cheminees from level 2 are reserved the same way.
- This applies bidirectionally by level: failles (level 1) affect level 2, cheminees (level 2) affect level 3.
- Reserved cells are only visible once the player has explored (revealed) them on the target level — they are not auto-revealed on descent.
- Once revealed, a reserved cell displays a glowing violet/magenta circle overlay instead of normal content.
- Tapping on a revealed passage cell shows a simple informational message (e.g., "Passage vers la Faille Alpha" or "Passage vers la Cheminee Primaire"), referencing the transition base name from the level below.
- No other interaction is possible on these cells (no attack, no explore action targeting them as content).

### US2 — Level-scoped exploration highlighting

**As a** player managing explorations across multiple levels,
**I want** pending exploration markers to only appear on the level where I ordered them,
**So that** I don't see confusing highlights on other levels.

**Acceptance criteria:**

- Pending exploration orders on level 2 only show their cyan border markers on the level 2 map view.
- Pending exploration orders on level 1 only show their cyan border markers on the level 1 map view.
- Same for level 3.
- Switching between levels via the level selector immediately reflects the correct set of pending explorations for that level only.

---

## 3. Testing and Validation

### Unit Tests

- **Content generation exclusion**: Verify that `MapGenerator` (or `ContentPlacer`) does not place any content at reserved passage positions when generating level 2 or 3.
- **Passage cell data**: Verify that cells at passage positions carry the correct metadata linking to the transition base from the level below.
- **Exploration filtering**: Verify that pending exploration targets are correctly filtered by level.

### Integration Tests

- **Full descent flow**: Descend to level 2, explore the area, and verify that faille positions from level 1 appear as passage markers with violet glow when revealed.
- **Multi-level highlight isolation**: Create explorations on level 1 and level 2, switch between levels, and verify that only the correct level's highlights are visible.

### Manual / Visual Tests

- Verify the violet/magenta circle renders correctly on passage cells.
- Verify the informational message displays the correct transition base name on tap.
- Verify no visual artifact remains on other levels when switching.

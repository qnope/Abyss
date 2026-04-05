# Map Interaction — Feature Specification

## 1. Feature Overview

This feature allows the player to send **Scouts** to explore the map. When a scout is sent to a target cell, the area around that cell is revealed at the next turn resolution. The size of the revealed area depends on the **Explorer tech branch** research level.

Scouts are **consumed** upon being sent — they do not return. Multiple scouts can be sent in a single turn to explore different areas simultaneously.

### Key Principles

- Exploration is the **only** way to reveal new cells beyond the initial 2-cell radius around the base.
- Exploration is a **queued action**: scouts are sent during the player's turn, but revelation happens during turn resolution.
- Once sent, an exploration order **cannot be cancelled**.

---

## 2. User Stories

### US-1: Send a Scout to Explore

**As a** player, **I want to** tap on a map cell and send a scout to explore it, **so that** I can reveal the fog of war around that cell.

**Acceptance Criteria:**
- Tapping an eligible cell on the map opens a bottom sheet confirming the exploration.
- The bottom sheet shows: target coordinates, the scout cost (1 scout), and the expected reveal area size.
- Confirming the action consumes 1 scout from the player's army immediately.
- The exploration order is stored and will be resolved at the next turn.
- If the player has 0 scouts, the confirmation sheet indicates the action is unavailable.

### US-2: Cell Eligibility for Exploration

**As a** player, **I want to** know which cells I can send a scout to, **so that** I explore the map progressively.

**Acceptance Criteria:**
- A cell is eligible if it is **already revealed**.
- A cell is also eligible if it is **not revealed but adjacent** (Chebyshev distance 1) to at least one revealed cell.
- Fault cells are eligible (no terrain restriction since Rock has been removed).
- The player's base cell is not a valid exploration target.

### US-3: Reveal Area Based on Explorer Research Level

**As a** player, **I want** my research investment to increase the area revealed per exploration, **so that** higher tech makes exploration more efficient.

**Acceptance Criteria:**
- The revealed area is a **square** centered on the target cell.
- The square size depends on the Explorer tech branch research level:

| Explorer Level | Square Side | Total Cells Revealed |
|----------------|-------------|----------------------|
| 0 (unlocked)   | 2           | 4                    |
| 1              | 3           | 9                    |
| 2              | 4           | 16                   |
| 3              | 5           | 25                   |
| 4              | 7           | 49                   |
| 5              | 9           | 81                   |

- For even-sized squares (2, 4), the target cell is at the **bottom-left corner** of the revealed area.
- Cells outside the map boundaries are simply ignored (no wrapping).
- Already-revealed cells are unaffected (revelation is idempotent).

### US-4: Multiple Explorations Per Turn

**As a** player, **I want to** send multiple scouts in a single turn, **so that** I can explore several areas at once.

**Acceptance Criteria:**
- The player can send as many scouts as they have available.
- Each exploration consumes exactly 1 scout.
- Each exploration order is stored independently and resolved during the same turn resolution.

### US-5: Exploration in Turn Confirmation Dialog

**As a** player, **I want to** see my pending explorations before confirming the turn, **so that** I know what will happen.

**Acceptance Criteria:**
- The turn confirmation dialog lists all pending exploration orders for this turn.
- Each entry shows the target coordinates and the expected reveal area size.
- The total number of scouts being consumed this turn is displayed.

### US-6: Exploration in Turn Summary Dialog

**As a** player, **I want to** see what was revealed after turn resolution, **so that** I know the exploration results.

**Acceptance Criteria:**
- The turn summary dialog includes an exploration section.
- It lists each exploration that was resolved: target coordinates and number of new cells revealed.
- If a revealed area uncovered notable content (monster lairs, ruins, resource bonuses), this is mentioned.

### US-7: Explorer Branch Level 0 Requirement

**As a** player, **I want** exploration to work even without unlocking the Explorer branch, **so that** I can explore early in the game.

**Acceptance Criteria:**
- At Explorer level 0 (branch not yet unlocked or unlocked but not researched), the reveal area is a 2x2 square.
- Unlocking the Explorer branch is **not** required to send scouts — it only improves the reveal area.

---

## 3. Testing and Validation

### Unit Tests

- **Reveal area calculation:** Verify the correct square size for each Explorer research level (0 through 5).
- **Cell eligibility:** Verify a cell is eligible if revealed, or if unrevealed but adjacent to a revealed cell. Verify the base cell is not eligible.
- **Scout consumption:** Verify 1 scout is removed per exploration order. Verify exploration is refused when 0 scouts available.
- **Boundary handling:** Verify exploring near map edges does not crash or wrap; cells outside boundaries are ignored.
- **Even square alignment:** Verify that for square sides 2 and 4, the target cell is at the bottom-left of the reveal area.
- **Turn resolution:** Verify pending explorations are resolved during turn resolution and cells are marked as revealed.
- **Multiple explorations:** Verify multiple exploration orders in the same turn are all resolved independently.
- **Idempotency:** Verify re-revealing already visible cells does not cause errors or side effects.

### Integration Tests

- **Full exploration flow:** Send a scout, pass a turn, verify the map state reflects the revealed cells.
- **Turn dialog integration:** Verify pending explorations appear in the turn confirmation dialog and results appear in the turn summary.

### Validation Criteria

- `flutter analyze` passes with no errors.
- `flutter test` passes all existing and new tests.
- All files remain under 150 lines of code.

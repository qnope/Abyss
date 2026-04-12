# End Game — Feature Specification

## 1. Feature Overview

The end-game feature introduces the **Volcanic Kernel**, the final objective of the game. A unique volcanic kernel is placed at the center of Level 3 (Noyau). The player must fight powerful guardians to capture it, then construct and upgrade the associated building to level 10 to win the game.

This feature closes the gameplay loop by providing a clear victory condition and a post-game screen with essential statistics.

## 2. User Stories

### US-1: Volcanic Kernel appears on the map

**As a** player exploring Level 3,
**I want** to discover a unique Volcanic Kernel cell at the center of the map,
**So that** I know where the final objective is.

**Acceptance criteria:**
- A single Volcanic Kernel cell is placed at or very near the center (10,10) of the Level 3 map during generation.
- The cell uses the `volcanic_kernel.svg` icon.
- The cell is hidden by fog of war until explored, like any other cell.
- The cell is visually distinct from other map content (monster lairs, treasures, ruins).

### US-2: Capture the Volcanic Kernel

**As a** player who has discovered the Volcanic Kernel,
**I want** to send my army to fight the guardians and capture it,
**So that** I can begin building toward victory.

**Acceptance criteria:**
- The Volcanic Kernel is guarded by a boss and minions, harder than the cheminee guardians (difficulty above 5/5).
- Guardian composition: a single powerful boss stronger than the Titan Volcanique (200 HP, 25 ATK, 15 DEF), accompanied by minions stronger than Golems de magma.
- Capture follows the same mechanic as transition bases: the player must win the fight AND the Abyss Admiral must survive.
- If the player wins but the Admiral dies, the guardians reform and the kernel remains uncaptured.
- If the player loses, units are lost and guardians reform.
- Once captured, the Volcanic Kernel cell is marked with the capturing player's ID.

### US-3: Build the Volcanic Kernel building

**As a** player who has captured the Volcanic Kernel,
**I want** to construct the Volcanic Kernel building,
**So that** I can start progressing toward victory.

**Acceptance criteria:**
- Once the Volcanic Kernel is captured, a new building type "Noyau Volcanique" becomes available in the standard building list.
- The building uses the `volcanic_kernel.svg` icon.
- Prerequisite: HQ must be at level 10.
- The building has 10 levels (max level 10).
- Costs are very high, especially in pearls, scaling with each level.
- The building appears in the same UI as other buildings (standard building list), even though it is logically located on Level 3.

### US-4: Victory condition

**As a** player whose Volcanic Kernel building reaches level 10,
**I want** to see a victory screen with my game statistics,
**So that** I feel a sense of accomplishment and can review my performance.

**Acceptance criteria:**
- When the Volcanic Kernel building is upgraded to level 10, the game triggers a victory state.
- A victory screen is displayed with essential statistics:
  - Total number of turns played
  - Total monsters defeated
  - Total transition bases (failles + cheminees) captured
  - Total resources collected (all types combined)
- The player can choose to:
  - **Continue playing** in free mode (the game continues normally, no further win/loss triggers)
  - **Return to menu** to start a new game

### US-5: Defeat condition (deferred implementation)

**As a** player,
**I want** to lose the game if a rival player builds the Volcanic Kernel to level 10 before me,
**So that** there is a competitive tension even in single-player.

**Acceptance criteria:**
- The system is designed so that when AI players are implemented, if any non-human player's Volcanic Kernel building reaches level 10, a defeat screen is shown.
- The defeat screen shows the same statistics as the victory screen, plus the name of the winning rival.
- The player can choose to return to menu.
- **Note:** This user story is specified but NOT implemented until AI/rival players are added. Only the data model and the condition check should be in place; the actual triggering is deferred.

## 3. Testing and Validation

### Unit Tests

- **Map generation**: Verify that Level 3 always contains exactly one Volcanic Kernel cell near the center.
- **Capture mechanics**: Test that capture follows transition base rules (fight + Admiral survival).
- **Guardian generation**: Verify guardian composition is correct and stronger than cheminee guardians.
- **Building prerequisites**: Verify HQ 10 is required, captured kernel is required.
- **Building costs**: Verify costs scale correctly and are pearl-heavy.
- **Victory trigger**: Verify that upgrading the building to level 10 sets the game state to victory.
- **Defeat trigger**: Verify that a non-human player reaching level 10 sets the game state to defeat (logic only, no AI to trigger it yet).
- **Post-game choices**: Verify that "continue" resumes normal gameplay with no further win/loss triggers, and "return to menu" works.

### Integration Tests

- **Full flow**: Capture kernel, build to level 10, verify victory screen appears with correct stats.
- **Statistics accuracy**: Verify that displayed stats match actual game state (turns, monsters, resources).

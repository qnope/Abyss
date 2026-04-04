# Add Army Feature Specification

## 1. Feature Overview

Add the **Army tab** to the game screen, replacing the current placeholder. This tab displays all unit types as cards. Units not yet unlocked (barracks level too low) appear greyed out. Unlocked units show their count and can be tapped to open a detail sheet with recruitment controls.

Recruitment is **instantaneous**: pay resources, get units immediately. One recruitment action per turn (can recruit N units of the same type in one action).

## 2. User Stories

### US-01: View army overview

**As a** player
**I want to** see all unit types in the Army tab
**So that** I know what units exist and which ones I can recruit.

**Acceptance criteria:**
- The Army tab shows 6 unit cards: Scout, Harpoonist, Guardian, Dome Breaker, Siphoner, Saboteur.
- Unlocked units display their icon, name, and current count.
- Locked units are greyed out (visually dimmed).
- Locked units show a lock indicator.

### US-02: View locked unit detail

**As a** player
**I want to** tap a locked unit card
**So that** I know what barracks level is required to unlock it.

**Acceptance criteria:**
- Tapping a locked unit opens a detail sheet.
- The sheet shows only the unit name and the message: "Caserne niveau X requise pour debloquer".
- No stats, no recruitment controls.

### US-03: View unlocked unit detail

**As a** player
**I want to** tap an unlocked unit card
**So that** I can see its stats and recruit units.

**Acceptance criteria:**
- Tapping an unlocked unit opens a detail sheet.
- The sheet displays: name, icon, HP, ATK, DEF, recruitment cost, and current count.
- A recruitment slider is shown (see US-04).

### US-04: Recruit units

**As a** player
**I want to** recruit units using a slider
**So that** I can build my army.

**Acceptance criteria:**
- The slider goes from 0 to `Min(barracksLevel * 100, maxAffordableFromResources(game, unitType))`.
- The total cost updates dynamically as the slider moves (cost = unitCost * sliderValue).
- A "Recruit" button confirms the action.
- On confirmation: resources are deducted, units are added to the army, the sheet closes.
- If the player has already recruited this turn, the slider is disabled with a message "Recrutement deja effectue ce tour".
- If the player cannot afford any unit, the slider max is 0 and the button is disabled.

## 3. Unit Types

### Unlock tiers (by barracks level)

| Barracks Level | Units Unlocked          |
|----------------|-------------------------|
| 1              | Scout, Harpoonist       |
| 3              | Guardian, Dome Breaker  |
| 5              | Siphoner, Saboteur      |

### Stats

| Unit         | HP | ATK | DEF | Role           |
|--------------|----|-----|-----|----------------|
| Scout        | 10 |   2 |   1 | Eclaireur      |
| Harpoonist   | 15 |   5 |   2 | DPS            |
| Guardian     | 25 |   2 |   6 | Tank           |
| Dome Breaker | 20 |   8 |   3 | Siege          |
| Siphoner     | 12 |   3 |   2 | Voleur         |
| Saboteur     |  8 |  10 |   1 | Verre-canon    |

### Recruitment costs

| Unit         | Algae | Coral | Ore | Energy | Pearl |
|--------------|-------|-------|-----|--------|-------|
| Scout        |    10 |     5 |   - |      - |     - |
| Harpoonist   |    15 |    10 |   5 |      - |     - |
| Guardian     |     - |    20 |  15 |      - |     - |
| Dome Breaker |     - |     - |  25 |     15 |     - |
| Siphoner     |    20 |     - |   - |     10 |     2 |
| Saboteur     |     - |    15 |   - |     20 |     3 |

## 4. Recruitment rules

- **Instantaneous**: resources are deducted and units appear immediately.
- **1 action per turn**: after one recruitment action, further recruitment is blocked until next turn.
- **Max recruitable**: `Min(barracksLevel * 100, floor(minOverResources(playerResource / unitCost)))` for each resource type required by the unit.
- **Tracking**: the game must track whether a recruitment action has been performed this turn. This flag resets at turn resolution.

## 5. Testing and Validation

- **Unit tests (domain)**:
  - Unit cost calculator: verify costs for each unit type.
  - Unit unlock calculator: verify which units are unlocked at each barracks level.
  - Max recruitable calculation: test with various resource/barracks combinations.
  - RecruitUnitAction: validate success, insufficient resources, already recruited this turn, locked unit.
  - RecruitUnitAction: execute deducts resources, adds units, sets recruited flag.
  - Turn resolution resets the recruited-this-turn flag.

- **Widget tests (presentation)**:
  - Army list shows 6 cards.
  - Locked units appear dimmed.
  - Tapping locked unit shows unlock message (no stats).
  - Tapping unlocked unit shows stats + slider.
  - Slider max respects the Min formula.
  - Recruit button disabled when already recruited this turn.

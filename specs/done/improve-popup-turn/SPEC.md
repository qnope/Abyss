# Improve Turn Popup - Feature Specification

## 1. Feature Overview

Improve the two turn dialogs (confirmation and summary) to show clear resource progression with before/after values, capping indicators, and army-related information. The goal is to give the player full visibility on what a turn resolution does to their game state.

Currently, the confirmation dialog only shows raw production numbers, and the summary dialog shows produced amounts with a capping boolean. After this improvement, both dialogs will show the format: `Resource before (+production) -> after`, with visual and textual indicators when a resource hits max storage. The summary dialog will additionally show army-related information (maintenance costs and recruitment availability).

## 2. User Stories

### US-01: Confirmation dialog shows predicted progression

**As a** player about to press "Tour suivant",
**I want** to see the predicted before/after values for each resource,
**So that** I can decide whether to confirm the turn or do more actions first.

**Acceptance Criteria:**
- The confirmation dialog shows the current turn number transitioning to the next (e.g., "Tour 3 -> Tour 4").
- Each resource line shows: `ResourceName currentAmount (+production) -> predictedAmount`.
- If the predicted amount would exceed max storage, the line is visually highlighted (different color, e.g., orange) and shows "(MAX)" after the predicted value.
- The predicted amount shown when capped is the max storage value, not the uncapped sum.
- The dialog has "Annuler" and "Confirmer" buttons.
- Resources with zero production are still displayed (with +0) for completeness.

### US-02: Summary dialog shows actual progression

**As a** player after turn resolution,
**I want** to see what actually changed during the turn,
**So that** I understand the impact of the turn on my resources.

**Acceptance Criteria:**
- The summary dialog shows the turn transition (e.g., "Tour 3 -> Tour 4").
- Each resource line shows: `ResourceName previousAmount (+production) -> newAmount`.
- If a resource was capped, the line is visually highlighted (different color) and shows "(MAX)".
- The before values are captured BEFORE the turn resolver modifies the game state.
- The after values reflect the actual post-resolution state.

### US-03: Army maintenance visible in resource progression

**As a** player with an army,
**I want** to see maintenance costs in the turn dialogs,
**So that** I understand how my army affects resource production.

**Acceptance Criteria:**
- If the player has units with maintenance costs, the production amount shown accounts for maintenance (net production).
- Example: if production is +50 algae but maintenance is -20 algae, the line shows `Algue 100 (+30) -> 130`.
- If net production is negative (maintenance exceeds production), the amount is shown in a warning color (e.g., red).
- Maintenance costs are visible in both the confirmation and summary dialogs.

### US-04: Recruitment availability in summary dialog

**As a** player after turn resolution,
**I want** to be informed that recruitment is available again,
**So that** I know I can recruit new units this turn.

**Acceptance Criteria:**
- After the resource progression section, a separate section shows army-related information.
- If the player had recruited units last turn, a message indicates "Recrutement disponible" (recruitment slots reset).
- If no units were recruited last turn, this section is not shown (no noise).
- This information only appears in the summary dialog, not the confirmation dialog.

## 3. Testing and Validation

### Domain Tests
- **TurnResult**: Verify the new data model captures before/after values for each resource.
- **TurnResolver**: Verify that before-values are correctly snapshot before mutation, and that maintenance costs are factored into production.
- **ProductionCalculator**: If maintenance is added here, test net production calculations.

### Widget Tests
- **TurnConfirmationDialog**: Verify predicted values display correctly, capping indicators show when appropriate, zero-production resources are shown.
- **TurnSummaryDialog**: Verify actual before/after values display, capping visual + text indicators, army section appears only when relevant.
- **Capping display**: Verify both color change and "(MAX)" text appear together on capped resources.
- **Negative net production**: Verify warning color when maintenance exceeds production.

### Integration Tests
- Full turn flow: confirm dialog -> resolve -> summary dialog, verifying data consistency between the two dialogs.

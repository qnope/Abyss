# Task 23: Create TransitionBase Bottom Sheet

## Summary
Create a bottom sheet displayed when tapping a transition base on the map. Shows name, type, difficulty, status, prerequisites, and action buttons (assault / descend / reinforce).

## Implementation Steps

1. **Create TransitionBaseSheet** in `lib/presentation/widgets/map/transition_base_sheet.dart`:
   ```dart
   class TransitionBaseSheet extends StatelessWidget {
     final TransitionBase transitionBase;
     final int level;
     final Player player;
     final VoidCallback? onAttack;
     final VoidCallback? onDescend;
     final VoidCallback? onReinforce;
   }
   ```

2. **Layout — Uncaptured state**:
   - Header: transition base name + type display name
   - Difficulty rating: "Difficulte: 4/5" or "5/5" with star icons
   - Status: "Neutre — Gardiens presents" in red
   - Prerequisite checklist:
     - [x] or [ ] "Module de Descente construit" (for faille)
     - [x] or [ ] "Capsule Pressurisee construite" (for cheminee)
   - Action button: "Assaut" (enabled only if prerequisites met)

3. **Layout — Captured state**:
   - Header: transition base name + type display name
   - Status: "Capturee" in cyan
   - Two action buttons:
     - "Descendre au Niveau X" (always available)
     - "Envoyer des renforts" (available if target level already explored)

4. **Prerequisite checking logic**:
   - Check `player.buildings[BuildingType.descentModule]?.level >= 1` for faille
   - Check `player.buildings[BuildingType.pressureCapsule]?.level >= 1` for cheminee

5. **Use AbyssTheme** for styling, matching existing sheet patterns (MonsterLairSheet, TreasureSheet)

## Dependencies
- **Internal**: Task 07 (TransitionBase), Task 09 (descent buildings), Task 20 (display extensions)
- **External**: AbyssTheme, existing sheet patterns

## Test Plan
- **File**: `test/presentation/widgets/map/transition_base_sheet_test.dart`
  - Verify uncaptured state shows difficulty and assault button
  - Verify assault button disabled without prerequisite building
  - Verify captured state shows descend and reinforce buttons
  - Verify reinforce button hidden when target level not yet explored
- Run `flutter analyze`

## Notes
- Follow the existing pattern from `MonsterLairSheet` for layout and styling.
- Keep under 150 lines — extract sub-widgets if needed.

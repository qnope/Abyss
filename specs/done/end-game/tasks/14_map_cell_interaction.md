# Task 14: Add volcanic kernel cell interaction on map

## Summary

When the player taps a volcanic kernel cell on the Level 3 map, show a bottom sheet with kernel info and attack/captured status.

## Implementation Steps

### 1. Create `lib/presentation/widgets/map/volcanic_kernel_sheet.dart`

Bottom sheet that shows:
- Title: "Noyau Volcanique"
- Description text based on state:
  - Not captured: "Le coeur brulant des abysses est garde par de puissants gardiens."
  - Captured: "Vous avez capture le Noyau Volcanique. Construisez le batiment pour remporter la victoire."
- If not captured: "Lancer l'assaut" button (calls `onAttack`)
- If captured: info only (no action)
- Icon: volcanic kernel SVG

```dart
void showVolcanicKernelSheet(
  BuildContext context, {
  required bool isCaptured,
  required VoidCallback onAttack,
}) { ... }
```

### 2. Edit `lib/presentation/screens/game/game_screen_map_actions.dart`

In `_showCellAction()`, replace the placeholder `CellContentType.volcanicKernel` case:

```dart
case CellContentType.volcanicKernel:
  final isCaptured = cell.collectedBy == human.id;
  showVolcanicKernelSheet(
    context,
    isCaptured: isCaptured,
    onAttack: () => handleAttackVolcanicKernel(
      context, game, repository,
      x, y, level, onChanged,
    ),
  );
```

### 3. Create handler in `lib/presentation/screens/game/game_screen_kernel_actions.dart`

```dart
void handleAttackVolcanicKernel(
  BuildContext context,
  Game game,
  GameRepository repository,
  int x, int y, int level,
  VoidCallback onChanged,
) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => KernelArmySelectionScreen(
        game: game,
        repository: repository,
        targetX: x,
        targetY: y,
        level: level,
        onChanged: onChanged,
      ),
    ),
  );
}
```

Import this file in `game_screen_map_actions.dart`.

## Dependencies

- Task 1: `CellContentType.volcanicKernel`
- Task 4: `build_runner`
- Task 15: `KernelArmySelectionScreen` (can be stubbed initially)

## Test Plan

- **File**: `test/presentation/widgets/map/volcanic_kernel_sheet_test.dart`
- Test: shows "Noyau Volcanique" title
- Test: when not captured, shows attack button
- Test: when captured, does NOT show attack button
- Test: attack button calls `onAttack` callback
- **File**: `test/presentation/screens/game/game_screen_map_actions_test.dart` (if exists, add tests)
- Test: tapping a volcanic kernel cell opens the kernel sheet

## Notes

- The kernel sheet follows the same pattern as `transition_base_sheet.dart`
- Import `game_screen_kernel_actions.dart` in `game_screen_map_actions.dart`

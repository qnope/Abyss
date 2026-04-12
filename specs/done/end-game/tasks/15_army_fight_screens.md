# Task 15: Create kernel army selection and fight summary screens

## Summary

Create the army selection screen for the volcanic kernel assault and the fight result summary screen, mirroring the transition base flow.

## Implementation Steps

### 1. Create `lib/presentation/screens/game/fight/kernel_army_selection_screen.dart`

Mirrors `TransitionArmySelectionScreen` with these differences:
- Title: `'Assaut: Noyau Volcanique'`
- Action: fires `AttackVolcanicKernelAction` instead of `AttackTransitionBaseAction`
- Result type: `AttackVolcanicKernelResult`
- Navigation: pushes `KernelFightSummaryScreen`

```dart
class KernelArmySelectionScreen extends StatefulWidget {
  final Game game;
  final GameRepository repository;
  final int targetX;
  final int targetY;
  final int level;
  final VoidCallback onChanged;
  // ... (no transitionBase param)
}
```

Key logic (same as transition version):
- `_selected` map tracks chosen unit quantities
- `_hasAdmiral` check required
- `_onLaunchPressed()` creates `AttackVolcanicKernelAction`, executes, saves, navigates

### 2. Create `lib/presentation/screens/game/fight/kernel_fight_summary_screen.dart`

Mirrors `TransitionFightSummaryScreen` with these differences:
- Takes `AttackVolcanicKernelResult` instead of `AttackTransitionBaseResult`
- Banner label: `'NOYAU CAPTURE'` when captured, `'VICTOIRE'` / `'DEFAITE'` otherwise
- AppBar title: `'Assaut Noyau Volcanique'`

```dart
class KernelFightSummaryScreen extends StatelessWidget {
  final AttackVolcanicKernelResult result;
  final int targetX;
  final int targetY;
  // ... (no transitionBase param)
}
```

Sections (reuse pattern from `TransitionFightSummaryScreen`):
- Result banner (captured/victory/defeat)
- Player unit accounting (sent/intact/wounded/dead)
- Monster section (guardians eliminated count)
- Fight turn list
- "Retour a la carte" button

## Dependencies

- Task 11: `AttackVolcanicKernelAction` + `AttackVolcanicKernelResult`
- Task 14: `handleAttackVolcanicKernel()` navigates here

## Test Plan

- **File**: `test/presentation/screens/game/fight/kernel_army_selection_screen_test.dart`
- Test: displays "Assaut: Noyau Volcanique" title
- Test: admiral required warning shown when no admiral selected
- Test: launch button disabled when no units selected
- Test: launch button disabled when no admiral
- **File**: `test/presentation/screens/game/fight/kernel_fight_summary_screen_test.dart`
- Test: shows "NOYAU CAPTURE" when captured
- Test: shows "VICTOIRE" when victory but not captured
- Test: shows "DEFAITE" when defeated
- Test: displays unit accounting rows
- Test: "Retour a la carte" button pops navigation

## Notes

- These screens deliberately duplicate the transition base screens rather than abstracting a shared base. This keeps each screen simple and self-contained (~80-100 lines each), matching the codebase's preference for small focused files.
- Shared widgets like `UnitQuantityRow`, `SelectionSummaryCard`, `FightTurnList` are reused directly.

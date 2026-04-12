# Task 11: Create `AttackVolcanicKernelAction`

## Summary

Create the action for attacking the volcanic kernel guardians and capturing the kernel. Follows the same capture mechanic as transition bases (victory + Admiral alive = capture).

## Implementation Steps

### 1. Add `attackVolcanicKernel` to `lib/domain/action/action_type.dart`

```dart
attackVolcanicKernel,
```

### 2. Create `lib/domain/action/attack_volcanic_kernel_result.dart`

Mirrors `AttackTransitionBaseResult`:

```dart
class AttackVolcanicKernelResult extends ActionResult {
  final bool victory;
  final bool captured;
  final FightResult? fight;
  final Map<UnitType, int> sent;
  final Map<UnitType, int> survivorsIntact;
  final Map<UnitType, int> wounded;
  final Map<UnitType, int> dead;

  AttackVolcanicKernelResult.success({...}) : super.success();
  const AttackVolcanicKernelResult.failure(super.reason) : ... super.failure();
}
```

### 3. Create `lib/domain/action/attack_volcanic_kernel_action.dart`

```dart
class AttackVolcanicKernelAction extends Action {
  final int targetX;
  final int targetY;
  final int level;  // always 3
  final Map<UnitType, int> selectedUnits;
  final Random? random;

  // ... constructor

  @override ActionType get type => ActionType.attackVolcanicKernel;
  @override String get description => 'Assaut Noyau Volcanique';
}
```

**`validate()`**:
1. Check `game.levels[level]` exists
2. Check cell at (targetX, targetY) has `content == CellContentType.volcanicKernel`
3. Check cell is not already captured (`collectedBy == null`)
4. Check `selectedUnits` includes at least 1 `abyssAdmiral`
5. Check all selected units are available in player's stock on `level`

**`execute()`**:
1. Call `validate()`, return if failure
2. Build player combatants via `CombatantBuilder.playerCombatantsFrom()`
3. Build guardians via `GuardianFactory.forVolcanicKernel()`
4. Remove units from stock via `AttackTransitionBaseHelpers.removeUnitsFromStock()`
5. Run fight via `FightEngine`
6. Resolve casualties via `AttackTransitionBaseHelpers.resolveCasualties()`
7. Check: victory AND admiral alive → captured
8. If captured: set `cell.collectedBy = player.id` on the map cell
9. Return `AttackVolcanicKernelResult.success(...)`

**`makeHistoryEntry()`**:
- Return a `CaptureEntry` with the kernel name "Noyau Volcanique" if captured
- Return a `CombatEntry` if not captured but fight happened

### 4. Updating the map cell

When captured, update the cell in `game.levels[level]`:
```dart
final map = game.levels[level]!;
final updatedCell = cell.copyWith(collectedBy: player.id);
map.setCell(targetX, targetY, updatedCell);
```

## Dependencies

- Task 1: `CellContentType.volcanicKernel`
- Task 4: `build_runner`
- Task 6: `GuardianFactory.forVolcanicKernel()`
- Task 9: capture state tracked via `collectedBy`

## Test Plan

- **File**: `test/domain/action/attack_volcanic_kernel_action_test.dart`
- Test: validate fails if cell is not volcanic kernel
- Test: validate fails if kernel already captured
- Test: validate fails if no admiral selected
- Test: validate fails if units exceed stock
- Test: execute with winning fight + admiral alive → captured, cell.collectedBy set
- Test: execute with winning fight + admiral dead → NOT captured, cell.collectedBy null
- Test: execute with losing fight → NOT captured, units lost
- Test: makeHistoryEntry returns CaptureEntry when captured
- Test: casualties properly resolved (survivors returned to stock)

## Notes

- Reuses `AttackTransitionBaseHelpers` for unit removal, admiral check, and casualty resolution — these methods operate on generic types
- The `isAdmiralAlive` check uses `AttackTransitionBaseHelpers.isAdmiralAlive()`
- The fight difficulty is ~6/5 given the guardian stats (harder than cheminee at 5/5)

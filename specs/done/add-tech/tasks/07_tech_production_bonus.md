# Task 07 — Tech Production Bonus

## Summary

Modify `ProductionCalculator` and `TurnResolver` so the Resources tech branch bonus (+20% per node) applies to all resource production.

## Implementation Steps

### 1. Update `lib/domain/production_calculator.dart`

Add an optional `techBranches` parameter:

```dart
class ProductionCalculator {
  static Map<ResourceType, int> fromBuildings(
    Map<BuildingType, Building> buildings, {
    Map<TechBranch, TechBranchState>? techBranches,
  }) {
    final result = <ResourceType, int>{};
    for (final building in buildings.values) {
      final formula = productionFormulas[building.type];
      if (formula != null && building.level > 0) {
        final amount = formula.compute(building.level);
        result[formula.resourceType] =
            (result[formula.resourceType] ?? 0) + amount;
      }
    }
    // Apply Resources tech branch bonus
    final resourcesLevel = techBranches?[TechBranch.resources]?.researchLevel ?? 0;
    if (resourcesLevel > 0) {
      final multiplier = 1.0 + (0.2 * resourcesLevel);
      for (final type in result.keys.toList()) {
        result[type] = (result[type]! * multiplier).floor();
      }
    }
    return result;
  }
}
```

Add imports for `tech_branch.dart` and `tech_branch_state.dart`.

### 2. Update `lib/domain/turn_resolver.dart`

Pass `techBranches` when calling `ProductionCalculator`:

```dart
final production = ProductionCalculator.fromBuildings(
  game.buildings,
  techBranches: game.techBranches,
);
```

### 3. Update `lib/presentation/screens/game_screen.dart`

Update both calls to `ProductionCalculator.fromBuildings` to pass `techBranches`:

- In `build()` method (line ~37):
  ```dart
  final production = ProductionCalculator.fromBuildings(
    widget.game.buildings,
    techBranches: widget.game.techBranches,
  );
  ```
- In `_nextTurn()` method (line ~89):
  ```dart
  final production = ProductionCalculator.fromBuildings(
    widget.game.buildings,
    techBranches: widget.game.techBranches,
  );
  ```

## Files

| Action | Path |
|--------|------|
| Edit | `lib/domain/production_calculator.dart` |
| Edit | `lib/domain/turn_resolver.dart` |
| Edit | `lib/presentation/screens/game_screen.dart` |

## Dependencies

- Task 01 (`TechBranch`).
- Task 02 (`TechBranchState`).
- Task 03 (`Game.techBranches`).

## Design Notes

- The optional parameter keeps backward compatibility — existing callers without tech still work (bonus = 0).
- `.floor()` rounds down the bonus to keep integer production amounts.
- Only the Resources branch applies immediately. Military and Explorer bonuses are stored but not yet consumed (spec says "will be applied when combat/map systems are implemented").
- Existing tests for `ProductionCalculator` should still pass since the parameter is optional.

## Test Plan

- **File:** `test/domain/production_calculator_test.dart` — add tests with tech branches.
- Test: no tech → production unchanged (regression).
- Test: resources branch level 1 → +20% on all resources.
- Test: resources branch level 5 → +100% on all resources.
- Test: military branch level 3 → no effect on production.
- Covered in task 14.

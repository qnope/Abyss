# Task 02: Player Model — Replace units with unitsPerLevel

## Summary
Replace `Player.units: Map<UnitType, Unit>` with `Player.unitsPerLevel: Map<int, Map<UnitType, Unit>>` to support multi-level unit tracking. Add `revealedCellsPerLevel: Map<int, List<GridPosition>>` to replace `revealedCellsList`. Add helper methods.

## Implementation Steps

1. **Update Player class** in `lib/domain/game/player.dart`:
   - Replace `@HiveField(7) final Map<UnitType, Unit> units` with `@HiveField(7) final Map<int, Map<UnitType, Unit>> unitsPerLevel`
   - Replace `@HiveField(10) final List<GridPosition> revealedCellsList` with `@HiveField(10) final Map<int, List<GridPosition>> revealedCellsPerLevel`
   - Add helper: `Map<UnitType, Unit> unitsOnLevel(int level) => unitsPerLevel[level] ?? {}`
   - Add helper: `List<GridPosition> revealedCellsOnLevel(int level) => revealedCellsPerLevel[level] ?? []`
   - Add helper: `Set<GridPosition> revealedCellsSetOnLevel(int level) => revealedCellsOnLevel(level).toSet()`
   - Update `revealedCells` getter → `revealedCellsSetOnLevel(1)` (backward compat)
   - Update `addRevealedCell` to take a `level` parameter
   - Update constructor defaults

2. **Update PlayerDefaults** in `lib/domain/game/player_defaults.dart`:
   - `units()` → returns `{1: {UnitType.scout: Unit(...), ...}}`
   - Or keep as `Map<UnitType, Unit>` and wrap in `{1: ...}` in Player constructor

3. **Update Player.withBase factory**:
   - `revealedCellsList` → `revealedCellsPerLevel: {1: _initialRevealedCells(...)}`

4. **Regenerate Hive adapters**: `dart run build_runner build --delete-conflicting-outputs`

## Dependencies
- **Internal**: Task 01 (siphoner renamed)
- **External**: None

## Test Plan
- **File**: `test/domain/game/player_test.dart`
  - Verify `unitsOnLevel(1)` returns Level 1 units
  - Verify `unitsOnLevel(2)` returns empty map when no Level 2 units
  - Verify `addRevealedCell(level, pos)` adds to correct level
- Run `flutter analyze` — zero warnings

## Notes
- Changing `@HiveField(7)` type breaks old saves. The existing try/catch in `GameRepository.initialize()` handles this by deleting and recreating the box.
- `recruitedUnitTypes` remains flat (recruitment always happens on Level 1 where the base is).

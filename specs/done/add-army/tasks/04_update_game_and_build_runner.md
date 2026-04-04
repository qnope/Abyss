# Task 04: Update Game Class, ActionType, and Run build_runner

## Summary

Add army-related fields to the `Game` class, add `recruitUnit` to `ActionType`, register new Hive adapters, and regenerate all `.g.dart` files.

## Implementation Steps

### 1. Update `lib/domain/game.dart`

Add two new HiveFields:

```dart
@HiveField(5)
final Map<UnitType, Unit> units;

@HiveField(6)
final List<UnitType> recruitedUnitTypes;
```

- `units`: initialized via `defaultUnits()` — a map of all 6 UnitTypes with count 0
- `recruitedUnitTypes`: initialized as empty `[]`
- Add `defaultUnits()` static method (same pattern as `defaultBuildings()`)
- Update constructor to accept optional `units` and `recruitedUnitTypes`

### 2. Update `lib/domain/action_type.dart`

Add `recruitUnit` value to the enum.

### 3. Update Hive registration in `lib/main.dart`

Register the new adapters:
- `Hive.registerAdapter(UnitTypeAdapter())`
- `Hive.registerAdapter(UnitAdapter())`

### 4. Run build_runner

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

This regenerates:
- `lib/domain/game.g.dart` (new fields 5, 6)
- `lib/domain/unit_type.g.dart` (new file, typeId 6)
- `lib/domain/unit.g.dart` (new file, typeId 7)

## Dependencies

- Task 01 (UnitType enum)
- Task 02 (Unit model)

## Test Plan

- **File**: `test/domain/game_test.dart` (update existing)
  - `Game()` has 6 default units, all with count 0
  - `Game()` has empty `recruitedUnitTypes`
  - Custom units can be provided to constructor
- Run `flutter analyze` to verify no errors after code generation

## Notes

- HiveField indices 5 and 6 are free on Game (existing fields use 0-4).
- `recruitedUnitTypes` is a `List<UnitType>` (not a Set) because Hive doesn't support Sets natively. Use `.contains()` for lookups and `.add()` for inserts. Clear on turn.
- TypeId summary: 0=Player, 1=Game, 2=ResourceType, 3=Resource, 4=BuildingType, 5=Building, 6=UnitType, 7=Unit.

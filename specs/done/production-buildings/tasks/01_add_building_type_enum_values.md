# Task 01 — Add BuildingType Enum Values

## Summary
Add the 4 production building enum values to `BuildingType` and regenerate the Hive adapter.

## Implementation Steps

### 1. Edit `lib/domain/building_type.dart`
Add 4 new values with sequential `@HiveField` indices (1–4):
```dart
@HiveType(typeId: 4)
enum BuildingType {
  @HiveField(0) headquarters,
  @HiveField(1) algaeFarm,
  @HiveField(2) coralMine,
  @HiveField(3) oreExtractor,
  @HiveField(4) solarPanel,
}
```

### 2. Regenerate Hive adapters
Run: `dart run build_runner build --delete-conflicting-outputs`

This will update `building_type.g.dart` to handle the 4 new enum values.

### 3. Verify
Run `flutter analyze` — no new warnings expected.

## Dependencies
- None (first task in the chain).

## Test Plan
- No new tests needed. Existing `test/domain/building_type_test.dart` should still pass.
- All downstream tasks depend on this.

## Notes
- HiveField indices must never be reused or reordered. Use 1, 2, 3, 4 for the new values.
- The exhaustive `switch` expressions in `BuildingCostCalculator` and `BuildingTypeExtensions` will cause compile errors until tasks 02 and 06 are completed. That's expected.

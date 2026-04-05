# Task 4: Test TurnResult New Fields

## Summary

Add tests for the new `consumed`, `deactivatedBuildings`, and `lostUnits` fields on `TurnResult` and `TurnResourceChange`.

## Implementation Steps

### 1. Update or create `test/domain/turn_result_test.dart`

#### Group: `TurnResourceChange`
- `consumed defaults to 0` → `TurnResourceChange(type: algae, produced: 50, wasCapped: false).consumed` == 0
- `consumed stores given value` → `TurnResourceChange(..., consumed: 12).consumed` == 12

#### Group: `TurnResult`
- `deactivatedBuildings defaults to empty` → `TurnResult(changes: []).deactivatedBuildings` == []
- `lostUnits defaults to empty` → `TurnResult(changes: []).lostUnits` == {}
- `stores deactivatedBuildings` → `TurnResult(changes: [], deactivatedBuildings: [BuildingType.oreExtractor]).deactivatedBuildings.length` == 1
- `stores lostUnits` → `TurnResult(changes: [], lostUnits: {UnitType.scout: 5}).lostUnits[UnitType.scout]` == 5

## Dependencies

- Task 3 (TurnResult must be updated)

## Test Plan

- Run: `flutter test test/domain/turn_result_test.dart`
- Run: `flutter test test/domain/turn_resolver_test.dart` (verify existing tests still pass)

## Notes

- Verify backward compatibility: existing TurnResult usages without new fields must compile and work

# Task 3: Update TurnResult for Consumption Data

## Summary

Extend `TurnResourceChange` and `TurnResult` to carry consumption information, deactivated buildings, and lost units.

## Implementation Steps

### 1. Update `lib/domain/turn_result.dart`

Add imports:
```dart
import 'building_type.dart';
import 'unit_type.dart';
```

**TurnResourceChange** — add `consumed` field:
```dart
class TurnResourceChange {
  final ResourceType type;
  final int produced;
  final int consumed;  // NEW — 0 for resources without consumption
  final bool wasCapped;

  const TurnResourceChange({
    required this.type,
    required this.produced,
    this.consumed = 0,
    required this.wasCapped,
  });
}
```

**TurnResult** — add deactivation and loss info:
```dart
class TurnResult {
  final List<TurnResourceChange> changes;
  final List<BuildingType> deactivatedBuildings;  // NEW
  final Map<UnitType, int> lostUnits;             // NEW

  const TurnResult({
    required this.changes,
    this.deactivatedBuildings = const [],
    this.lostUnits = const {},
  });
}
```

## Dependencies

- `lib/domain/building_type.dart`
- `lib/domain/unit_type.dart`
- `lib/domain/resource_type.dart` (already imported)

## Test Plan

- File: `test/domain/turn_result_test.dart` (update existing if present, or handled by Task 4)
- Verify default values for new fields
- Verify existing tests still pass (new fields have defaults, so backward-compatible)

## Notes

- Default values (`consumed = 0`, `deactivatedBuildings = const []`, `lostUnits = const {}`) ensure all existing code compiles without changes
- File stays well under 150 lines

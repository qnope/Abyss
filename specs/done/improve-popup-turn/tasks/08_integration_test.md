# Task 8: Integration test — full turn flow

## Summary

Write an integration test that exercises the full turn flow: setup game state → confirmation dialog → turn resolution → summary dialog, verifying data consistency.

## Implementation Steps

### 1. Create integration test file

**File**: `test/presentation/screens/game_screen_turn_test.dart`

Create a focused integration test for the turn flow:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/game.dart';
import 'package:abyss/domain/player.dart';
import 'package:abyss/domain/building.dart';
import 'package:abyss/domain/building_type.dart';
import 'package:abyss/domain/resource.dart';
import 'package:abyss/domain/resource_type.dart';
import 'package:abyss/domain/unit.dart';
import 'package:abyss/domain/unit_type.dart';
import 'package:abyss/domain/production_calculator.dart';
import 'package:abyss/domain/maintenance_calculator.dart';
import 'package:abyss/domain/turn_resolver.dart';
```

### 2. Test cases

**group('Turn flow data consistency', ...)**:

- `confirmation prediction matches resolver result` — Setup game with algae farm level 2, 10 scouts. Compute net production the way GameScreen does. Then run TurnResolver. Verify the predicted after-values match actual after-values in TurnResult.

- `capping is consistent between prediction and result` — Setup game with resource near max (e.g., algae at 4900/5000, farm level 2 producing 140). Verify both prediction and TurnResult show capping.

- `maintenance deducted correctly through full flow` — Setup game with no production buildings + 20 scouts. Verify algae decreases by 20 and beforeAmount/afterAmount reflect this.

- `negative net production floors at zero` — Setup game with algae at 10, no production, 20 scouts (maintenance 20). Verify afterAmount is 0, not negative.

- `recruitment flag tracks correctly` — Add units to recruitedUnitTypes, resolve, verify hadRecruitedUnits=true and list is cleared.

- `turn numbers track correctly` — Start at turn 5, resolve, verify previousTurn=5, newTurn=6.

- `multiple resources with mixed production and maintenance` — Algae farm + coral mine + 10 scouts. Verify algae has net=production-10, coral has net=production, both have correct before/after.

### 3. Widget-level integration test (optional, if time permits)

**File**: `test/presentation/screens/game_screen_turn_test.dart`

If feasible within 150 lines, add a widget test that:
- Creates a `GameScreen` with a mock repository
- Taps "Tour suivant" button
- Verifies confirmation dialog shows correct turn transition
- Taps "Confirmer"
- Verifies summary dialog shows consistent data

## Dependencies

- **All previous tasks** (1-7) must be complete

## Test Plan

- **File**: `test/presentation/screens/game_screen_turn_test.dart`
- Run: `flutter test test/presentation/screens/game_screen_turn_test.dart`
- Run: `flutter test` — full test suite must pass
- Run: `flutter analyze` — zero issues

## Notes

- This test validates that the prediction shown in the confirmation dialog would match what TurnResolver actually computes, ensuring the player sees accurate data
- The test uses domain-level objects directly rather than widget testing for speed and reliability
- Keep the test file under 150 lines — focus on the most critical consistency checks

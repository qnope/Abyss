# Task 19: Integration test — full end-game flow

## Summary

Write an integration test that validates the complete end-game flow: map generation with volcanic kernel, capture, building construction up to level 10, and victory trigger.

## Implementation Steps

### 1. Create `test/integration/end_game_integration_test.dart`

```dart
void main() {
  group('End-game flow', () {
    // Test the full lifecycle:
    // 1. Generate Level 3 map → verify volcanic kernel at center
    // 2. Attack volcanic kernel → capture it
    // 3. Build volcanic kernel building from 0 to 10
    // 4. Verify victory state
  });
}
```

### Test cases

**Test 1: Level 3 map contains volcanic kernel**
- `MapGenerator.generate(level: 3, seed: 42)` → map
- Find cell with `content == CellContentType.volcanicKernel`
- Assert exactly one such cell exists
- Assert position is at (10, 10)

**Test 2: Capture volcanic kernel**
- Set up a game with Level 3 map
- Give player strong enough units on level 3 (many high-level units)
- Execute `AttackVolcanicKernelAction` with fixed random seed for deterministic fight
- Assert result is captured (victory + admiral alive)
- Assert `game.isVolcanicKernelCapturedBy(player.id)` is true

**Test 3: Build volcanic kernel to level 10**
- Use game from test 2 (kernel captured)
- Set HQ to level 10
- Give player massive resources
- Loop 10 times: execute `UpgradeBuildingAction(buildingType: volcanicKernel)`
- Assert each upgrade succeeds
- Assert final level is 10

**Test 4: Victory triggered**
- Use game from test 3 (building at level 10)
- Call `VictoryChecker.check(game)`
- Assert returns `GameStatus.victory`

**Test 5: Free play after victory**
- Set `game.status = GameStatus.freePlay`
- Call `VictoryChecker.check(game)` 
- Assert returns null (no further triggers)

**Test 6: Statistics accuracy**
- Use game from test 3
- Call `GameStatisticsCalculator.compute(game)`
- Assert `turnsPlayed == game.turn`
- Assert `basesCaptured >= 1` (at least the kernel)
- Assert `monstersDefeated > 0` (kernel guardians)

### Helper setup

Create a helper function to build a game ready for end-game testing:
```dart
Game _endGameReadyGame() {
  // Player with HQ 10, strong army on level 3, lots of resources
  // Level 3 map generated with seed
}
```

## Dependencies

- All previous tasks (1-18) must be complete

## Test Plan

This IS the test — run with:
```bash
flutter test test/integration/end_game_integration_test.dart
```

## Notes

- Use fixed random seeds for deterministic fight outcomes
- Give the player overwhelmingly strong units to guarantee victory in the fight
- The integration test validates the DOMAIN layer end-to-end (no widget tests here — those are in tasks 14-18)
- Follow existing integration test patterns from `test/integration/`

# Task 30: Tests — Descent and Reinforcement Actions

## Summary
Unit tests for `DescendAction`, `SendReinforcementsAction`, and reinforcement transit resolution in `TurnResolver`.

## Implementation Steps

1. **Create test file** `test/domain/action/descend_action_test.dart`:
   - `Fails if transition base not captured`: uncaptured faille → fail
   - `Fails if no units selected`: empty selection → fail
   - `Fails without descentModule`: module not built → fail
   - `Generates Level 2 map on first descent`: verify `game.levels[2]` populated
   - `Does not regenerate map on second descent`: verify same map object
   - `Units transferred from Level 1 to Level 2`: verify counts
   - `Level 1 unit count decremented`: verify source level
   - `Revealed cells initialized on Level 2`: verify initial fog reveal
   - `Units arrive at spawn point area`

2. **Create test file** `test/domain/action/send_reinforcements_action_test.dart`:
   - `Fails if target level has no map`: no prior descent → fail
   - `Fails if transition base not captured`: fail
   - `Creates ReinforcementOrder with correct fields`
   - `Units removed from source level immediately`
   - `departTurn matches current game turn`

3. **Create/update test file** `test/domain/turn/turn_resolver_test.dart`:
   - `Reinforcements arrive after 1 turn`: create order on turn 5, resolve turn 5→6, verify arrival
   - `Reinforcements not yet arrived`: create order on turn 5, resolve turn 5, verify still pending
   - `Multiple reinforcement orders resolved in same turn`
   - `Units added to target level correctly`
   - `Pending list cleared after arrival`

## Dependencies
- **Internal**: Tasks 14-15 (actions), Task 17 (TurnResolver)
- **External**: None

## Test Plan
- Self — this IS the test task
- Run `flutter test test/domain/action/descend_action_test.dart`
- Run `flutter test test/domain/action/send_reinforcements_action_test.dart`
- Run `flutter test test/domain/turn/turn_resolver_test.dart`

## Notes
- Create test helpers to quickly set up a game with a captured transition base for reuse across tests.

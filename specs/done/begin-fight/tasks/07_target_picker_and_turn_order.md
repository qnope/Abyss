# Task 07 - TargetPicker and TurnOrder

## Summary

Two tiny random utilities the fight engine needs:
- `TargetPicker.pickRandom` selects a random alive combatant from the
  opposing camp.
- `TurnOrder.shuffle` produces the global attack order for a given
  turn (all alive combatants from both camps interleaved randomly).

## Implementation steps

1. Create `lib/domain/fight/target_picker.dart`:
   - Class `TargetPicker` (stateless, static methods only).
   - `static Combatant? pickRandom(List<Combatant> pool, Random random)`
     -- filters `pool` down to alive combatants, returns null if empty,
     otherwise returns one at a random index.

2. Create `lib/domain/fight/turn_order.dart`:
   - Class `TurnOrder` (stateless, static methods only).
   - `static List<Combatant> shuffle(List<Combatant> playerSide, List<Combatant> monsterSide, Random random)`:
     1. Build a new list with all alive combatants from both sides.
     2. `list.shuffle(random)`.
     3. Return it.

## Dependencies

- **Internal**: `Combatant` (Task 04).
- **External**: `dart:math.Random`.

## Test plan

- New `test/domain/fight/target_picker_test.dart`:
  - Pool with a single alive target returns that target.
  - Pool with all dead combatants returns null.
  - Pool with mixed alive/dead never returns a dead combatant over
    100 seeded rolls.
  - Over 1000 seeded rolls, each alive combatant is selected roughly
    uniformly (loose bound).

- New `test/domain/fight/turn_order_test.dart`:
  - Output contains every alive combatant from both sides exactly once.
  - Dead combatants are excluded.
  - With `Random(42)` then `Random(43)`, the two orders differ
    (regression against a bug where the shuffle is no-op).
  - Ordering is deterministic given a seeded random.

## Notes

- Both files should stay < 40 lines.
- Pure Dart, no state.

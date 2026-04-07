# Task 03 — Create CollectTreasureAction

## Summary

Create a domain action that handles collecting treasures from both `resourceBonus` and `ruins` cells. The action validates the cell state, adds resources to the player's stock, and marks the cell as collected.

## Implementation Steps

1. **Create `lib/domain/action/collect_treasure_action.dart`**

   ```dart
   class CollectTreasureAction extends Action {
     final int targetX;
     final int targetY;
     final Random _random;

     CollectTreasureAction({
       required this.targetX,
       required this.targetY,
       Random? random,
     }) : _random = random ?? Random();
   ```

   - `type` getter returns `ActionType.collectTreasure`
   - `description` returns `'Collecter ($targetX, $targetY)'`

2. **Implement `validate(Game game)`**
   - Return failure if `game.gameMap == null` → `'Carte non générée'`
   - Get cell at `(targetX, targetY)`
   - Return failure if `!cell.isRevealed` → `'Case non révélée'`
   - Return failure if `cell.isCollected` → `'Déjà collecté'`
   - Return failure if `cell.content` is not `resourceBonus` or `ruins` → `'Rien à collecter'`
   - Return success

3. **Implement `execute(Game game)`**
   - Call validate; return on failure
   - Get the cell
   - **If resourceBonus:**
     - Get `cell.bonusResourceType` and `cell.bonusAmount`
     - Add amount to `game.resources[bonusResourceType]!.amount` (cap at `maxStorage`)
   - **If ruins:**
     - Pick a random `ResourceType` (excluding pearl): `_random.nextInt(4)` → algae/coral/ore/energy
     - Pick random amount: `20 + _random.nextInt(61)` (20–80)
     - Pick random pearls: `1 + _random.nextInt(5)` (1–5)
     - Add resource amount to stock (capped at maxStorage)
     - Add pearls to pearl stock (capped at maxStorage)
   - Mark cell as collected: `game.gameMap!.setCell(targetX, targetY, cell.copyWith(isCollected: true))`
   - Return success

## Dependencies

- Task 01 (`isCollected` field on MapCell)
- Task 02 (`collectTreasure` ActionType)

## Test Plan

- **File:** `test/domain/action/collect_treasure_action_test.dart` (task 05)

## Notes

- The `Random` parameter allows deterministic testing via a seeded `Random`.
- Resources are capped at `maxStorage` to avoid exceeding storage limits.
- The action is **immediate** — no pending order, no turn resolution.

# Turn Module

`lib/domain/turn/`

This module resolves the end-of-turn sequence and packages the results for UI display.

## Files

| File | Description |
|------|-------------|
| `turn_resolver.dart` | Multi-step turn resolution logic |
| `turn_result.dart` | `TurnResult` and `TurnResourceChange` data classes |

## TurnResolver

`TurnResolver.resolve(Game game)` mutates the game state and returns a `TurnResult`. The resolution follows a strict sequence:

```
 1. Calculate production from active buildings (with tech bonuses)
                        |
 2. Read current energy production and stock
                        |
 3. Deactivate buildings if energy is insufficient (BuildingDeactivator)
                        |
 4. Recalculate production using only active buildings
                        |
 5. Read algae production and stock
                        |
 6. Calculate unit losses if algae is insufficient (UnitLossCalculator)
                        |
 7. Apply unit losses (reduce unit counts)
                        |
 8. Recalculate consumption after losses
                        |
 9. Apply net resource changes (production - consumption, capped by storage)
                        |
10. Resolve pending explorations (ExplorationResolver)
                        |
11. Resolve pending reinforcements (deliver arrived units)
                        |
12. Clear recruited units list, increment turn counter
                        |
12. Return TurnResult
```

Key behaviors:
- When energy is insufficient, `BuildingDeactivator` selects buildings to shut down. Production is then recalculated with those buildings treated as level 0.
- When algae is insufficient, `UnitLossCalculator` determines how many units are lost. Unit counts are reduced before final consumption is computed.
- Resource amounts are clamped: never below 0, never above `maxStorage`.

## TurnResult

Packages the outcomes of a single turn resolution so the UI can display what happened.

| Field | Type | Description |
|-------|------|-------------|
| `changes` | `List<TurnResourceChange>` | Per-resource breakdown of production, consumption, and final amounts |
| `previousTurn` | `int` | Turn number before resolution |
| `newTurn` | `int` | Turn number after resolution |
| `hadRecruitedUnits` | `bool` | Whether units were recruited during the turn |
| `deactivatedBuildings` | `List<BuildingType>` | Buildings shut down due to energy shortage |
| `lostUnits` | `Map<UnitType, int>` | Units lost due to algae shortage |
| `explorations` | `List<ExplorationResult>` | Exploration outcomes (cells revealed, notable content) |
| `arrivedReinforcements` | `int` | Number of reinforcement orders that arrived this turn |

## TurnResourceChange

Per-resource detail for a single turn.

| Field | Type | Description |
|-------|------|-------------|
| `type` | `ResourceType` | Which resource |
| `produced` | `int` | Amount produced this turn |
| `consumed` | `int` | Amount consumed this turn |
| `wasCapped` | `bool` | Whether production was capped by max storage |
| `beforeAmount` | `int` | Stock before the turn |
| `afterAmount` | `int` | Stock after the turn |

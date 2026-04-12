# Action Module

## Overview

The action module implements the **Command pattern**. Each player
action (upgrading a building, recruiting units, etc.) is encapsulated
as an `Action` object that can be validated against the current game
state and then executed to mutate it.

Every action receives **both** the `Game` container and the `Player`
it is acting on. Per-player state (resources, buildings, tech, units,
revealed cells, pending explorations) is always read from the
`Player` argument -- actions never dig into `Game` for those fields.
`Game` is only consulted for shared world state such as `gameMap`.

## Action (abstract base class)

`Action` defines the contract every concrete action must follow:

- `ActionType get type` -- identifies the action kind via the
  `ActionType` enum.
- `String get description` -- human-readable label.
- `ActionResult validate(Game game, Player player)` -- checks whether
  the action is legal for `player` given `game`. Returns
  `ActionResult.success()` or `ActionResult.failure(reason)`. Must not
  mutate anything.
- `ActionResult execute(Game game, Player player)` -- performs the
  action by mutating `player` (and, where unavoidable, shared state
  such as `gameMap` cells for collection). Implementations re-validate
  internally before applying changes.

## ActionType

An enum listing all action kinds: `upgradeBuilding`, `unlockBranch`,
`researchTech`, `recruitUnit`, `explore`, `collectTreasure`,
`fightMonster`, `attackTransitionBase`, `attackVolcanicKernel`,
`descend`, `sendReinforcements`, `endTurn`.

## ActionResult

A simple result object with two named constructors:

- `ActionResult.success()` -- `isSuccess = true`, `reason = null`.
- `ActionResult.failure(String reason)` -- `isSuccess = false`, carries
  an explanation.

### CollectTreasureResult

Sub-class of `ActionResult` returned by `CollectTreasureAction`.
Carries `Map<ResourceType, int> deltas` so the presentation layer can
show what was actually gained (post-clamp at `maxStorage`).

### FightMonsterResult

Sub-class of `ActionResult` returned by `FightMonsterAction`. On
success it carries:

- `victory` -- `true` if the player side won.
- `fight` -- the full `FightResult` from the engine (turn-by-turn
  summaries, initial/final combatants, monster counts).
- `loot` -- `Map<ResourceType, int>` of resources actually added
  (post-clamp, empty on defeat).
- `sent` -- units the player committed (non-zero entries only).
- `survivorsIntact` -- units that survived unscathed, grouped by
  `UnitType`.
- `wounded` -- units that fell but returned to the stock.
- `dead` -- units that fell and were lost for good.

The failure constructor carries a French reason string and empty
maps.

## ActionExecutor

A thin orchestrator enforcing the validate-then-execute sequence:

1. `action.validate(game, player)`.
2. If validation fails, return the failure result immediately.
3. Otherwise `action.execute(game, player)`.
4. If the result is successful, call
   `action.makeHistoryEntry(game, player, result, game.turn)` and, if
   it returns a non-null entry, append it to the player via
   `player.addHistoryEntry(entry)` (which enforces the 100-entry FIFO).
5. Return the execute result.

This guarantees no action reaches `execute` without passing validation
first, and that the history log only ever records **successful**
actions.

### `Action.makeHistoryEntry`

The base `Action` class exposes an overridable hook:

```dart
HistoryEntry? makeHistoryEntry(
  Game game,
  Player player,
  ActionResult result,
  int turn,
) => null;
```

Every concrete action in this module overrides it to return the
matching [`HistoryEntry`](../history/README.md) subclass (or `null`
when there is nothing worth logging). Actions read from the mutated
`player` / `result` to materialise post-execute state (e.g. the new
building level), so the hook must be called **after** `execute`.

## Concrete Actions

### UpgradeBuildingAction

Takes a `BuildingType`. Validates against `player.buildings` and
`player.resources`. On execute, deducts the upgrade cost and
increments the building level on the player.

### RecruitUnitAction

Takes a `UnitType` and a `quantity`. Validates against the player's
barracks level, `player.recruitedUnitTypes`, quantity, and
`player.resources`. On execute, deducts costs on the player, bumps
`player.units`, and marks the unit type as recruited this turn.

### ResearchTechAction

Takes a `TechBranch`. Validates against `player.techBranches` (must be
unlocked, not at max), `player.buildings[BuildingType.laboratory]`,
and `player.resources`. On execute, deducts costs and increments the
branch research level on the player.

### UnlockBranchAction

Takes a `TechBranch`. Validates that the branch exists on the player,
is not already unlocked, a laboratory is present (level >= 1), and
resources are sufficient. On execute, deducts costs and unlocks the
branch on the player.

### ExploreAction

Takes a `targetX` and `targetY`. Validates that `game.gameMap` exists,
the player has at least one scout, and the target cell is eligible
for that player (via `CellEligibilityChecker` using
`player.revealedCells` and the player's base). On execute, decrements
the scout count and appends an `ExplorationOrder` to
`player.pendingExplorations`. Scout consumption is immediate;
revelation happens at turn resolution.

### CollectTreasureAction

Takes `targetX`, `targetY`, and an optional `Random` (for tests).
Validates that `game.gameMap` exists, the cell is revealed for the
player, not yet collected, and contains `resourceBonus` or `ruins`.
On execute, rolls rewards, adds them to `player.resources` (clamped
to `maxStorage`), flags the cell with `collectedBy = player.id` on
the shared map, and returns a `CollectTreasureResult`.

| Content type     | Reward roll                                                  |
|------------------|--------------------------------------------------------------|
| `resourceBonus`  | algae 50-100, coral 30-50, ore 30-50 (no pearl)              |
| `ruins`          | algae 0-100, coral 0-25, ore 0-25, pearl 0-2                 |

Collection is free and immediate (no scout, no turn delay).

### FightMonsterAction

Takes `targetX`, `targetY`, a `selectedUnits: Map<UnitType, int>`
(the units the player commits to the fight), and an optional `Random`
for tests.

**Validation** -- all of:

- `game.gameMap` exists.
- The target cell's content is `monsterLair` and it is not already
  collected.
- `cell.lair` is non-null.
- Every `selectedUnits` entry is within the player's current stock.
- At least one unit is selected.

Failures return a `FightMonsterResult.failure(reason)` with a French
message so the UI can show it directly.

**Execution flow**:

1. Build both combatant lists via `CombatantBuilder`. The player side
   is built with `playerCombatantsFrom(selectedUnits,
   militaryResearchLevel: FightMonsterHelpers.militaryResearchLevelOf(player))`,
   which reads `player.techBranches[TechBranch.military].researchLevel`
   (or `0` if the branch is missing or locked). The monster side uses
   `monsterCombatantsFrom(lair)`.
2. Decrement the player stocks by the committed amounts **before**
   resolving the fight.
3. Run `FightEngine(random: random).resolve(...)`.
4. Compute `pctLost` from initial vs final player HP via
   `FightMonsterHelpers.computePctLost`.
5. Group final player combatants into `alive` (intact survivors) and
   `fallen` (hp == 0, mapped back to their initial entries).
6. Partition `fallen` into `wounded` / `dead` via
   `CasualtyCalculator.partition`. Restore both `alive` (intact
   survivors) and `split.wounded` to player stocks via
   `FightMonsterHelpers.restoreToStock`. The invariant
   `stock_final == stock_initial - dead` holds.
7. On victory: roll loot via `LootCalculator`, apply it via
   `FightMonsterHelpers.applyLoot` (clamped at `maxStorage`), and mark
   the cell as collected by the player (`copyWith(collectedBy:
   player.id)`).
8. Return a `FightMonsterResult.success(...)` with the full fight
   result plus `sent` / `survivorsIntact` / `wounded` / `dead` /
   `loot`.

On defeat, the lair stays on the map -- the player can re-engage
later with a fresh army.

### AttackTransitionBaseAction

Takes a `TransitionBase`, `selectedUnits: Map<UnitType, int>`, a
`level: int`, and an optional `Random`.

**Validation**: at least one abyssAdmiral, required building built
(descentModule for faille, pressureCapsule for cheminee), base not
already captured, units available on the given level.

**Execution**: builds player combatants vs guardian combatants from
`GuardianFactory`, runs the fight engine, then:
- Victory + abyssAdmiral alive → base captured (`capturedBy = player.id`)
- Victory + no admiral → survivors return, no capture
- Defeat → army lost, guardians reform

Returns an `AttackTransitionBaseResult` with fight details and outcome.

### AttackVolcanicKernelAction

Takes `targetX`, `targetY`, `level` (always 3),
`selectedUnits: Map<UnitType, int>`, and an optional `Random`.

**Validation**: volcanic kernel cell exists at the target, not already
captured, player has the selected units on the given level, at least
one `abyssAdmiral` is selected.

**Execution**: builds player combatants vs volcanic kernel guardians
from `GuardianFactory.forVolcanicKernel()`, runs the fight engine,
then:
- Victory + abyssAdmiral alive → kernel captured
  (`cell.collectedBy = player.id`)
- Victory + no admiral → survivors return, no capture
- Defeat → army lost, kernel remains

Returns an `AttackVolcanicKernelResult` with the fight details and
capture outcome. History entry is a `CaptureEntry` on capture, or a
`CombatEntry` otherwise.

### DescendAction

Takes a `TransitionBase`, `selectedUnits: Map<UnitType, int>`, and
`level: int`.

**Validation**: base must be captured by the player, required building
built, units available, target level derived from base type.

**Execution**: if the target level has no map yet, generates one via
`MapGenerator.generate(level: targetLevel)`. Removes units from source
level, adds them to target level. One-way transfer (no ascent).

### SendReinforcementsAction

Takes a `TransitionBase`, `selectedUnits`, and `level: int`.

**Validation**: base captured, target level map exists, units available.

**Execution**: removes units from source level immediately, creates a
`ReinforcementOrder` with 1-turn transit time, appended to
`player.pendingReinforcements`. Resolution happens in `TurnResolver`.

### EndTurnAction

Wraps `TurnResolver` so that "next turn" flows through the uniform
`Action` + `ActionExecutor` pipeline. `validate` always succeeds
(ending a turn is never gated), and `execute` delegates to
`TurnResolver().resolve(game)` and wraps the result in an
`EndTurnActionResult`. The `makeHistoryEntry` override turns the
resolved `TurnResult` into a `TurnEndEntry` via `TurnEndEntryFactory`,
tagged with `tr.previousTurn` — the turn that just ended — because
`TurnResolver` has already advanced `game.turn` by the time the hook
runs. Routing "end turn" through the executor is what makes the
history log homogeneous: every logged event, including the turn
boundary itself, is a successful `Action` result.

## File Map

| File | Role |
|---|---|
| `action.dart` | Abstract `Action` base class |
| `action_type.dart` | `ActionType` enum |
| `action_result.dart` | `ActionResult` value object |
| `collect_treasure_result.dart` | `CollectTreasureResult` sub-class |
| `fight_monster_result.dart` | `FightMonsterResult` sub-class |
| `action_executor.dart` | `ActionExecutor` orchestrator |
| `upgrade_building_action.dart` | `UpgradeBuildingAction` |
| `recruit_unit_action.dart` | `RecruitUnitAction` |
| `research_tech_action.dart` | `ResearchTechAction` |
| `unlock_branch_action.dart` | `UnlockBranchAction` |
| `explore_action.dart` | `ExploreAction` |
| `collect_treasure_action.dart` | `CollectTreasureAction` |
| `fight_monster_action.dart` | `FightMonsterAction` |
| `fight_monster_helpers.dart` | Pct-lost, generic `restoreToStock`, loot apply, military level lookup, combatants-by-type helpers, `buildCombatEntry` for the history log |
| `attack_transition_base_action.dart` | `AttackTransitionBaseAction` |
| `attack_transition_base_helpers.dart` | Transition base combat helpers |
| `attack_transition_base_result.dart` | `AttackTransitionBaseResult` |
| `attack_volcanic_kernel_action.dart` | `AttackVolcanicKernelAction` |
| `attack_volcanic_kernel_helpers.dart` | Volcanic kernel combat helpers |
| `attack_volcanic_kernel_result.dart` | `AttackVolcanicKernelResult` |
| `descend_action.dart` | `DescendAction` |
| `send_reinforcements_action.dart` | `SendReinforcementsAction` |
| `end_turn_action.dart` | `EndTurnAction` |
| `end_turn_action_result.dart` | `EndTurnActionResult` (carries the resolved `TurnResult`) |

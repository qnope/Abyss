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
`researchTech`, `recruitUnit`, `explore`, `collectTreasure`.

## ActionResult

A simple result object with two named constructors:

- `ActionResult.success()` -- `isSuccess = true`, `reason = null`.
- `ActionResult.failure(String reason)` -- `isSuccess = false`, carries
  an explanation.

### CollectTreasureResult

Sub-class of `ActionResult` returned by `CollectTreasureAction`.
Carries `Map<ResourceType, int> deltas` so the presentation layer can
show what was actually gained (post-clamp at `maxStorage`).

## ActionExecutor

A thin orchestrator enforcing the validate-then-execute sequence:

1. `action.validate(game, player)`.
2. If validation fails, return the failure result immediately.
3. Otherwise `action.execute(game, player)` and return its result.

This guarantees no action reaches `execute` without passing validation
first.

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

## File Map

| File | Role |
|---|---|
| `action.dart` | Abstract `Action` base class |
| `action_type.dart` | `ActionType` enum |
| `action_result.dart` | `ActionResult` value object |
| `collect_treasure_result.dart` | `CollectTreasureResult` sub-class |
| `action_executor.dart` | `ActionExecutor` orchestrator |
| `upgrade_building_action.dart` | `UpgradeBuildingAction` |
| `recruit_unit_action.dart` | `RecruitUnitAction` |
| `research_tech_action.dart` | `ResearchTechAction` |
| `unlock_branch_action.dart` | `UnlockBranchAction` |
| `explore_action.dart` | `ExploreAction` |
| `collect_treasure_action.dart` | `CollectTreasureAction` |

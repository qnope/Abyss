# Action Module

## Overview

The action module implements the **Command pattern**. Each player action (upgrading a building, recruiting units, etc.) is encapsulated as an `Action` object that can be validated against the current game state and then executed to mutate it.

## Action (abstract base class)

`Action` defines the contract every concrete action must follow:

- `ActionType get type` -- identifies the action kind via the `ActionType` enum.
- `String get description` -- human-readable label for the action.
- `ActionResult validate(Game game)` -- checks whether the action is legal given the current `Game` state (sufficient resources, correct building level, etc.). Returns `ActionResult.success()` or `ActionResult.failure(reason)`. Must not mutate the game.
- `ActionResult execute(Game game)` -- performs the action by mutating the `Game`. Every concrete implementation re-validates internally before applying changes.

## ActionType

An enum listing all action kinds: `upgradeBuilding`, `unlockBranch`, `researchTech`, `recruitUnit`, `explore`, `collectTreasure`.

## ActionResult

A simple result object with two named constructors:

- `ActionResult.success()` -- `isSuccess = true`, `reason = null`.
- `ActionResult.failure(String reason)` -- `isSuccess = false`, carries an explanation string.

### CollectTreasureResult

Sub-class of `ActionResult` returned by `CollectTreasureAction`. Carries `Map<ResourceType, int> deltas` so the presentation layer can show what was actually gained (post-clamp at `maxStorage`).

## ActionExecutor

A thin orchestrator that enforces the validate-then-execute sequence:

1. Calls `action.validate(game)`.
2. If validation fails, returns the failure result immediately.
3. Otherwise calls `action.execute(game)` and returns its result.

This guarantees no action reaches `execute` without passing validation first.

## Concrete Actions

### UpgradeBuildingAction

Takes a `BuildingType`. Validates that the building exists, is not at max level, and the player has enough resources. On execute, deducts the upgrade cost from resources and increments the building level.

### RecruitUnitAction

Takes a `UnitType` and a `quantity`. Validates that the unit is unlocked (based on barracks level), the unit type has not already been recruited this turn, the quantity is positive, and resources are sufficient. On execute, deducts costs, increases the unit count, and marks the unit type as recruited for the current turn.

### ResearchTechAction

Takes a `TechBranch`. Validates that the branch exists, is unlocked, the target research level does not exceed the maximum, the laboratory level is high enough, and resources are sufficient. On execute, deducts costs and increments the branch research level.

### UnlockBranchAction

Takes a `TechBranch`. Validates that the branch exists, is not already unlocked, a laboratory is present (level >= 1), and resources are sufficient. On execute, deducts costs and sets the branch to unlocked.

### ExploreAction

Takes a `targetX` and `targetY`. Validates that the map exists, at least one scout is available, and the target cell is eligible (via `CellEligibilityChecker`). On execute, decrements the scout count and appends an `ExplorationOrder` to `game.pendingExplorations`. Scout consumption is immediate; revelation happens at turn resolution.

### CollectTreasureAction

Takes a `targetX`, `targetY`, and an optional `Random` source (for deterministic tests). Validates that the map exists, the target cell is revealed, not yet collected, and contains either `resourceBonus` or `ruins`. On execute, rolls the rewards, adds them to the player stock (clamped to `maxStorage`), flags the cell as collected, and returns a `CollectTreasureResult` carrying the per-resource delta actually applied.

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
| `collect_treasure_result.dart` | `CollectTreasureResult` sub-class of `ActionResult` carrying per-resource deltas |
| `action_executor.dart` | `ActionExecutor` orchestrator |
| `upgrade_building_action.dart` | `UpgradeBuildingAction` |
| `recruit_unit_action.dart` | `RecruitUnitAction` |
| `research_tech_action.dart` | `ResearchTechAction` |
| `unlock_branch_action.dart` | `UnlockBranchAction` |
| `explore_action.dart` | `ExploreAction` |
| `collect_treasure_action.dart` | `CollectTreasureAction` |

# Action System — Architecture

## Overview

The action system encapsulates game actions (upgrade, build, research…) as first-class domain objects. Each action knows how to validate and execute itself against a `Game`. An `ActionExecutor` serves as the single entry point, enforcing validation before execution.

## Domain Model

```
ActionType (enum, not persisted)
  upgradeBuilding | unlockBranch | researchTech | recruitUnit

ActionResult (immutable)
  ├── isSuccess: bool
  └── reason: String?
  Constructors: ActionResult.success(), ActionResult.failure(reason)

Action (abstract)
  ├── type: ActionType
  ├── description: String
  ├── validate(Game) → ActionResult
  └── execute(Game) → ActionResult

UpgradeBuildingAction extends Action
  ├── buildingType: BuildingType
  ├── validate → delegates to BuildingCostCalculator.checkUpgrade()
  └── execute → deducts resources, increments level

UnlockBranchAction extends Action
  ├── branch: TechBranch
  ├── validate → checks lab built, branch locked, resources
  └── execute → deducts resources, sets unlocked = true

ResearchTechAction extends Action
  ├── branch: TechBranch
  ├── validate → checks branch unlocked, sequential, lab level, resources
  └── execute → deducts resources, increments researchLevel

RecruitUnitAction extends Action
  ├── unitType: UnitType
  ├── count: int
  ├── validate → checks barracks level, resources, per-turn limit
  └── execute → deducts resources, increments unit count, marks type as recruited

ActionExecutor (stateless)
  └── execute(Action, Game) → ActionResult
        validate first, then execute
```

## Execution Flow

```
UI calls ActionExecutor.execute(action, game)
  │
  ├── action.validate(game) → failure? → return failure (game untouched)
  │
  └── action.execute(game) → mutates game → return success
```

## Integration with GameScreen

```
Before:  GameScreen._upgradeBuilding() → inline cost calc + manual mutation
After:   GameScreen._upgradeBuilding() → UpgradeBuildingAction + ActionExecutor
```

The presentation layer (`UpgradeSection`, `BuildingDetailSheet`) still uses `BuildingCostCalculator` directly for display. Only the mutation path goes through actions.

## Design Decisions

1. **Action as domain object** — Encapsulates intent + validation + execution. Same action class works for player and future AI.
2. **Defensive double validation** — Both `ActionExecutor` and `execute()` validate. Ensures safety regardless of call path.
3. **Stateless executor** — No dependencies, easy to test. Future concerns (logging, history, undo) slot in here.
4. **ActionResult over exceptions** — Explicit success/failure flow. UI can display failure reasons without try-catch.
5. **Player/AI parity** — Both use the same `Action` objects and `ActionExecutor`, ensuring identical game rules.

## File Structure

```
lib/domain/
  ├── action_type.dart
  ├── action_result.dart
  ├── action.dart
  ├── upgrade_building_action.dart
  ├── unlock_branch_action.dart
  ├── research_tech_action.dart
  ├── recruit_unit_action.dart
  └── action_executor.dart
test/domain/
  ├── action_result_test.dart
  ├── upgrade_building_action_test.dart
  ├── unlock_branch_action_test.dart
  ├── research_tech_action_test.dart
  ├── action_executor_test.dart
  └── recruit_unit_action_test.dart
```

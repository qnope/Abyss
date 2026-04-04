# Tech System — Architecture

## Overview

The technology tree lets the player research upgrades across 3 branches: Military, Resources, and Explorer. Each branch has 5 sequential nodes. The Resources branch immediately boosts production; the other two store bonuses for future systems.

## Domain Model

```
TechBranch (enum, Hive typeId: 6)
  military | resources | explorer

TechBranchState (HiveObject, typeId: 7)
  ├── branch: TechBranch
  ├── unlocked: bool         (mutable, false by default)
  └── researchLevel: int     (mutable, 0–5)

TechNodeState (enum, not persisted)
  locked | accessible | researched    (visual state only)

TechCostCalculator (stateless)
  ├── unlockCost(branch) → Map<ResourceType, int>
  ├── researchCost(branch, level) → Map<ResourceType, int>
  ├── requiredLabLevel(level) → int
  ├── maxResearchLevel = 5
  ├── checkUnlock(...) → TechCheck
  └── checkResearch(...) → TechCheck

TechCheck (immutable result)
  ├── canAct, isMaxLevel, branchLocked, previousNodeMissing
  ├── missingResources: Map<ResourceType, int>
  └── requiredLabLevel / currentLabLevel

Game.techBranches: Map<TechBranch, TechBranchState>
  └── Defaults via Game.defaultTechBranches()
```

## Unlock & Research Flow

```
[Lab built?] → no → entire tree greyed out
     ↓ yes
[Branch locked?] → tap → TechBranchDetailSheet → [Débloquer] → UnlockBranchAction
     ↓ unlocked
[Next node] → tap → TechNodeDetailSheet → [Rechercher] → ResearchTechAction
```

Both actions follow the standard Action pattern (validate → execute via ActionExecutor).

## Costs

**Branch unlock:** Military (ore 30, energy 20), Resources (coral 30, algae 20), Explorer (energy 30, ore 20).

**Research per node (levels 1–5):** Progressive costs with pearls at levels 4–5. Each branch uses two primary resources matching its theme.

## Production Bonus

`ProductionCalculator.fromBuildings()` accepts an optional `techBranches` parameter. The Resources branch applies `+20% × researchLevel` (floored) to all resource production. Military and Explorer bonuses are stored for future combat and map systems.

## Design Decisions

1. **Follows building system patterns** — Stateless calculator, result object (TechCheck), map keyed by enum.
2. **Sequential research** — Node N requires node N-1. No skipping, enforced by `ResearchTechAction`.
3. **Lab as prerequisite gate** — Lab level must equal research level (lab 3 for node 3). Mirrors HQ gating buildings.
4. **Optional techBranches parameter** — `ProductionCalculator` stays backward-compatible. No tech = no bonus.
5. **Three visual states** — locked/accessible/researched computed at render time from domain state, not stored.

## File Structure

```
lib/domain/
  ├── tech_branch.dart
  ├── tech_branch_state.dart
  ├── tech_node_state.dart
  ├── tech_check.dart
  ├── tech_cost_calculator.dart
  ├── unlock_branch_action.dart
  └── research_tech_action.dart
lib/presentation/
  ├── extensions/tech_branch_extensions.dart
  ├── screens/game_screen_tech_actions.dart
  └── widgets/
        ├── tech_node_widget.dart
        ├── tech_tree_view.dart
        ├── tech_branch_detail_sheet.dart
        └── tech_node_detail_sheet.dart
```

# Tech Domain

## Tech Branches

`TechBranch` is a Hive-persisted enum with three values:

- **military** -- primary resource: ore, secondary: energy
- **resources** -- primary resource: coral, secondary: algae
- **explorer** -- primary resource: energy, secondary: ore

## State Tracking

### TechBranchState

Hive-persisted object holding per-branch progress:

| Field          | Type       | Description                            |
|----------------|------------|----------------------------------------|
| `branch`       | TechBranch | Which branch this state belongs to     |
| `unlocked`     | bool       | Whether the branch has been unlocked   |
| `researchLevel`| int        | 0 = none, 1-5 = researched node depth  |

### TechNodeState

Simple enum representing the state of a single node in a branch:
`locked`, `accessible`, `researched`.

## TechCheck

Value object returned by validation methods in `TechCostCalculator`. It bundles all the reasons an action might be blocked:

- `canAct` -- overall pass/fail
- `isMaxLevel` -- target level exceeds the cap of 5
- `missingResources` -- map of each resource type the player still needs
- `requiredLabLevel` / `currentLabLevel` -- laboratory level gate
- `branchLocked` -- branch has not been unlocked yet
- `previousNodeMissing` -- earlier node in the branch is not yet researched

## TechCostCalculator

Static utility that computes costs and runs prerequisite checks.

- **`unlockCost(branch)`** -- fixed two-resource cost to unlock a branch.
- **`researchCost(branch, level)`** -- scaled cost using `_scaledCost`. Levels 1-3 require the two branch resources; levels 4-5 also require pearls.
- **`requiredLabLevel(researchLevel)`** -- the laboratory level needed equals the target research level.
- **`checkUnlock(...)`** -- returns a `TechCheck` verifying the branch is not already unlocked, the laboratory is at least level 1, and the player can afford the unlock cost.
- **`checkResearch(...)`** -- returns a `TechCheck` verifying the branch is unlocked, the target level is within bounds (max 5), the previous node is researched, the laboratory level is sufficient, and the player can afford the research cost.

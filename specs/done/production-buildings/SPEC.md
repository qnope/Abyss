# Production Buildings — Feature Specification

## 1. Feature Overview

Add the 4 resource production buildings from the game design: **Ferme d'algues**, **Mine de corail**, **Extracteur de minerai**, and **Panneau solaire**. Each building produces one of the 4 main resources. They are present from the start at level 0 (unbuilt) and can be upgraded up to level 5. The HQ gates their upgrade level. Upgrading a production building increases the `productionPerTurn` of its associated resource.

### Buildings

| Building | Enum value | Resource produced | Icon |
|----------|-----------|-------------------|------|
| Ferme d'algues | `algaeFarm` | algae | `assets/icons/buildings/algae_farm.svg` |
| Mine de corail | `coralMine` | coral | `assets/icons/buildings/coral_mine.svg` |
| Extracteur de minerai | `oreExtractor` | ore | `assets/icons/buildings/ore_extractor.svg` |
| Panneau solaire | `solarPanel` | energy | `assets/icons/buildings/solar_panel.svg` |

### Max Level

All 4 production buildings have a max level of **5**.

### HQ Prerequisites

| Production building level | Required HQ level |
|--------------------------|-------------------|
| 1 (build) | 1 |
| 2 | 2 |
| 3 | 4 |
| 4 | 6 |
| 5 | 10 |

This applies identically to all 4 production buildings.

### Upgrade Costs

Same formula as HQ: `base * (N^2 + 1)` where N = current level.

| Building | Cost resources | Base values |
|----------|---------------|-------------|
| Ferme d'algues | coral | coral: 20 |
| Mine de corail | ore | ore: 15 |
| Extracteur de minerai | coral, energy | coral: 25, energy: 15 |
| Panneau solaire | coral, ore | coral: 20, ore: 15 |

### Production Bonus

Upgrading a production building increases the `productionPerTurn` of its associated resource. Formula: `base * N` where N = building level.

| Building | Resource | Base production per level |
|----------|----------|--------------------------|
| Ferme d'algues | algae | 5 per level (lv1=5, lv2=10, lv3=15, lv4=20, lv5=25) |
| Mine de corail | coral | 4 per level (lv1=4, lv2=8, lv3=12, lv4=16, lv5=20) |
| Extracteur de minerai | ore | 3 per level (lv1=3, lv2=6, lv3=9, lv4=12, lv5=15) |
| Panneau solaire | energy | 3 per level (lv1=3, lv2=6, lv3=9, lv4=12, lv5=15) |

The production bonus is applied by modifying `Resource.productionPerTurn` after a successful upgrade. Note: the actual per-turn resource collection (adding `productionPerTurn` to `amount` on next turn) is NOT part of this project — it will be wired later.

### Default Buildings at Game Start

All 4 production buildings are present in `Game.defaultBuildings()` at level 0 (unbuilt, greyed out), alongside the existing HQ at level 0.

## 2. User Stories

**US-01: See production buildings in the building list**
As a player, I see all 4 production buildings in my building list from turn 1, greyed out at level 0.

Acceptance criteria:
- All 4 buildings appear in the BuildingListView
- They are displayed with their dedicated SVG icon
- Level 0 buildings appear dimmed (existing greyscale behavior)

**US-02: Build a production building**
As a player, I can build a production building (level 0 to 1) if I have sufficient resources and the required HQ level.

Acceptance criteria:
- Tapping a production building opens BuildingDetailSheet with costs and prerequisites
- If HQ is not the required level, the upgrade button is disabled and missing prerequisites are shown
- If resources are insufficient, the upgrade button is disabled and missing resources are shown in red
- On successful build, resources are deducted, building level becomes 1, production bonus is applied

**US-03: Upgrade a production building**
As a player, I can upgrade a production building up to level 5 if I meet the HQ prerequisite and have enough resources.

Acceptance criteria:
- Each upgrade level shows the correct cost (base * (N^2 + 1))
- HQ prerequisite is enforced and displayed when not met
- Upgrade deducts resources, increments level, and updates productionPerTurn
- At level 5, "Niveau maximum atteint" is displayed

**US-04: Production bonus visible**
As a player, I see my updated production rate in the resource bar after upgrading a production building.

Acceptance criteria:
- After upgrading a production building, the corresponding resource's productionPerTurn increases
- The ResourceBar reflects the updated production rate

## 3. Testing and Validation

### Unit tests
- **BuildingCostCalculator**: upgrade costs for each new building at various levels
- **BuildingCostCalculator**: max level returns 5 for each production building
- **BuildingCostCalculator**: prerequisites return correct HQ levels for each production building level
- **BuildingCostCalculator.checkUpgrade**: fails when HQ prerequisite not met
- **UpgradeBuildingAction**: works correctly with production buildings (validate + execute)
- **Production bonus**: productionPerTurn is updated after executing an upgrade action

### Widget tests
- BuildingListView displays all 5 buildings
- BuildingDetailSheet shows correct costs and prerequisites for production buildings
- BuildingDetailSheet shows missing HQ prerequisite when not met

### Regression
- All existing tests must continue to pass
- HQ upgrade behavior unchanged

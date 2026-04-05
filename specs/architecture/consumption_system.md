# Consumption System — Architecture

## Overview

Buildings consume energy and units consume algae each turn. When resources are insufficient, buildings are deactivated (energy) and units are lost (algae). This creates a strategic balancing act between expansion and sustainability.

## Domain Model

```
ConsumptionCalculator (stateless, all static)
  ├── buildingEnergyConsumption(type, level) → int
  ├── totalBuildingConsumption(buildings, {excluded}) → int
  ├── unitAlgaeConsumption(type) → int
  └── totalUnitConsumption(units) → int

BuildingDeactivator (stateless, all static)
  └── deactivate({buildings, energyProduction, energyStock}) → List<BuildingType>

UnitLossCalculator (stateless, all static)
  └── calculateLosses({units, algaeProduction, algaeStock}) → Map<UnitType, int>
```

## Consumption Rates

### Energy (buildings)

Formula: `multiplier × level` per turn.

| Building | Multiplier |
|----------|-----------|
| SolarPanel | 1 |
| AlgaeFarm | 2 |
| CoralMine | 2 |
| Headquarters | 3 |
| OreExtractor | 3 |
| Barracks | 3 |
| Laboratory | 4 |

### Algae (units)

Fixed cost per unit, multiplied by count.

| Unit | Cost/unit |
|------|----------|
| Scout | 1 |
| Harpoonist | 2 |
| Siphoner | 2 |
| Saboteur | 2 |
| Guardian | 3 |
| Dome Breaker | 3 |

## Deactivation Priority

When energy is insufficient (production + stock < total consumption), buildings are deactivated from lowest to highest priority until consumption fits:

```
7. OreExtractor    ← disabled first
6. CoralMine
5. AlgaeFarm
4. Laboratory
3. Barracks
2. SolarPanel
1. Headquarters    ← never disabled
```

## Unit Loss Algorithm

When algae is insufficient, losses are **proportional** across all unit types:
1. `deficit = totalConsumption - (algaeProduction + algaeStock)`
2. `lossRatio = deficit / totalConsumption`
3. Each type loses `ceil(count × lossRatio)` units

## Turn Resolution Integration

```
TurnResolver.resolve(game)
  ├── 1. Compute production (all buildings)
  ├── 2. Compute energy consumption → compare with production + stock
  ├── 3. Deactivate buildings if deficit (BuildingDeactivator)
  ├── 4. Recompute production (active buildings only)
  ├── 5. Compute algae consumption → compare with production + stock
  ├── 6. Calculate unit losses if deficit (UnitLossCalculator)
  ├── 7. Apply losses to game state
  ├── 8. Recompute consumption after losses
  ├── 9. Apply resource changes (amount += produced - consumed)
  └── 10. Return TurnResult with deactivatedBuildings + lostUnits
```

## Presentation

| Component | Role |
|-----------|------|
| `ResourceBarItem` | Shows `+prod/-cons/t` with red alert when deficit |
| `TurnConfirmationDialog` | Pre-turn warnings for deactivations and losses |
| `TurnSummaryDialog` | Post-turn display of actual deactivations and losses |
| `GameScreenTurnHelpers` | Computes predictions for the confirmation dialog |

## Design Decisions

1. **Deactivation is per-turn** — Buildings are not permanently disabled; they automatically reactivate when energy is sufficient.
2. **Proportional unit losses** — Fair distribution across all types rather than killing cheapest first.
3. **Consumption from production first** — Stock acts as a buffer, not the primary source.
4. **Deactivated buildings don't consume** — Removing their consumption frees energy for remaining buildings.
5. **Prediction matches resolution** — `GameScreenTurnHelpers` mirrors `TurnResolver` logic for accurate pre-turn warnings.

## File Structure

```
lib/domain/
  ├── consumption_calculator.dart
  ├── building_deactivator.dart
  └── unit_loss_calculator.dart
lib/presentation/
  ├── screens/game_screen_turn_helpers.dart
  └── widgets/resource_bar_item.dart (updated)
test/domain/
  ├── consumption_calculator_test.dart
  ├── building_deactivator_test.dart
  ├── unit_loss_calculator_test.dart (if exists)
  └── consumption_integration_test.dart
test/presentation/widgets/
  └── turn_summary_dialog_test.dart (updated)
```

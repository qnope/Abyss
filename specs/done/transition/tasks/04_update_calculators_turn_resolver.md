# Task 04: Update Calculators and TurnResolver for unitsPerLevel

## Summary
Update all calculators and the TurnResolver to work with `unitsPerLevel`. Consumption sums across all levels (shared economy). Unit losses apply to Level 1 first (starvation affects base garrison).

## Implementation Steps

1. **ConsumptionCalculator** (`lib/domain/resource/consumption_calculator.dart`):
   - Update `totalUnitConsumption` to accept `Map<int, Map<UnitType, Unit>>` or create an `allUnits` aggregation helper
   - Sum consumption across all levels

2. **MaintenanceCalculator** (`lib/domain/resource/maintenance_calculator.dart`):
   - Update `fromUnits` to sum across all levels

3. **UnitLossCalculator** (`lib/domain/unit/unit_loss_calculator.dart`):
   - Update to work with `unitsPerLevel`
   - Apply starvation losses starting from Level 1

4. **ProductionCalculator** (`lib/domain/resource/production_calculator.dart`):
   - No change needed (production is from buildings, not units)

5. **TurnResolver** (`lib/domain/turn/turn_resolver.dart`):
   - Replace all `player.units` references with appropriate `unitsPerLevel` access
   - Consumption calculation: use aggregated units across all levels
   - Unit loss application: apply to all levels proportionally

6. **ExplorationResolver** (`lib/domain/map/exploration_resolver.dart`):
   - Update revealed cell handling to use `revealedCellsPerLevel` and `addRevealedCell(level, pos)`
   - Default to Level 1 for existing exploration flow

7. **CombatantBuilder** (`lib/domain/fight/combatant_builder.dart`):
   - Update `playerCombatantsFrom` if it reads from `player.units`

## Dependencies
- **Internal**: Task 02 (Player model), Task 03 (actions updated)
- **External**: None

## Test Plan
- **File**: `test/domain/resource/consumption_calculator_test.dart`
  - Verify consumption sums units from all levels
- **File**: `test/domain/turn/turn_resolver_test.dart`
  - Verify turn resolution with multi-level units
- Run `flutter analyze` and `flutter test`

## Notes
- Production stays on Level 1 only (buildings are Level 1). No change needed for production.
- For unit losses, distribute proportionally across levels or apply to Level 1 first. Implementation can choose the simpler approach (proportional).

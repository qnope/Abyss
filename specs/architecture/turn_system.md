# Turn System — Architecture

## Overview

The turn system resolves a full game turn when the player presses "Next Turn": confirmation dialog with predicted progression, resource production with maintenance costs and storage capping, auto-save, and post-turn summary with before/after values.

## Domain Model

```
TurnResourceChange (immutable)
  ├── type: ResourceType
  ├── produced: int
  ├── consumed: int             (energy/algae consumption)
  ├��─ wasCapped: bool
  ├── beforeAmount: int
  └── afterAmount: int

TurnResult (immutable)
  ├── changes: List<TurnResourceChange>
  ├── previousTurn: int
  ���── newTurn: int
  ├── hadRecruitedUnits: bool
  ├── deactivatedBuildings: List<BuildingType>
  └─�� lostUnits: Map<UnitType, int>

TurnResolver (stateless)
  └── resolve(Game) → TurnResult
        Snapshots before-values → computes net production → applies → caps → increments turn

MaintenanceCalculator (stateless)
  └── fromUnits(Map<UnitType, Unit>) → Map<ResourceType, int>
        Sums per-unit maintenance costs across the army
```

## Turn Resolution Flow

```
Player taps "Tour suivant"
  │
  ├── Compute production, consumption, predicted deactivations/losses
  ├── Show TurnConfirmationDialog (predictions + warnings)
  │     ├── Cancel → abort (game untouched)
  │     └── Confirm ↓
  │
  ├── TurnResolver.resolve(game)
  │     ├── Snapshot before-values for each resource
  │     ├── ProductionCalculator.fromBuildings() → production map
  │     ├── ConsumptionCalculator → energy/algae consumption
  │     ├── BuildingDeactivator → deactivate if energy deficit
  │     ├── Recompute production (active buildings only)
  │     ├── UnitLossCalculator → proportional losses if algae deficit
  │     ├── For each resource: amount += produced - consumed
  │     ├── Clamp to [0, maxStorage]
  │     ├── Track wasCapped, beforeAmount, afterAmount
  │     ├── Record deactivatedBuildings, lostUnits, hadRecruitedUnits
  │     ├── game.recruitedUnitTypes.clear()
  │     └── game.turn++
  │
  ├── GameRepository.save(game)
  │
  ├── setState() → UI refreshes
  │
  └── Show TurnSummaryDialog (actual before/after + army info)
```

## Presentation

| Widget | Role |
|--------|------|
| `showTurnConfirmationDialog()` | Pre-turn: shows production/consumption predictions, warns about deactivations and unit losses |
| `showTurnSummaryDialog()` | Post-turn: shows actual changes with `+produced/-consumed`, deactivated buildings, and lost units |

Both are top-level functions returning dialog results. Private `StatelessWidget` classes handle the UI.

### Visual Indicators

- **Capped resources**: orange text + "(MAX)" suffix
- **Negative net production**: red text (consumption exceeds production)
- **Zero net production**: dimmed text
- **Building deactivation warnings**: warning icon in warning color
- **Unit loss warnings**: error icon in error color

## Design Decisions

1. **TurnResolver is stateless** — Instantiated per call, easy to test, no lifecycle.
2. **Immutable result objects** — `TurnResult` carries before/after feedback for the summary dialog without coupling domain to UI.
3. **Separate produced/consumed fields** — `TurnResourceChange` tracks production and consumption independently for clear UI display.
4. **Consumption system** — See [consumption_system.md](consumption_system.md) for deactivation/loss details.
5. **Floor at zero** — Resources cannot go negative; if maintenance exceeds production + current amount, the amount is floored at 0.
6. **Async flow in GameScreen** — `_nextTurn()` is async, chaining confirm → resolve → save → summary with `mounted` guards.

## File Structure

```
lib/domain/
  ├── turn_result.dart            # TurnResourceChange + TurnResult
  ├── turn_resolver.dart          # Stateless resolver
  ├── consumption_calculator.dart # Energy/algae consumption
  ├── building_deactivator.dart   # Priority-based deactivation
  └── unit_loss_calculator.dart   # Proportional unit losses
lib/presentation/
  ├── screens/game_screen_turn_helpers.dart
  └── widgets/
        ├── turn_confirmation_dialog.dart
        └── turn_summary_dialog.dart
test/domain/
  ├── turn_resolver_test.dart
  ├── consumption_calculator_test.dart
  ├── building_deactivator_test.dart
  └── consumption_integration_test.dart
test/presentation/widgets/
  ├── turn_confirmation_dialog_test.dart
  └── turn_summary_dialog_test.dart
test/presentation/screens/
  └── game_screen_turn_test.dart   # Turn flow integration tests
```

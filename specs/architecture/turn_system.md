# Turn System — Architecture

## Overview

The turn system resolves a full game turn when the player presses "Next Turn": confirmation dialog with predicted progression, resource production with maintenance costs and storage capping, auto-save, and post-turn summary with before/after values.

## Domain Model

```
TurnResourceChange (immutable)
  ├── type: ResourceType
  ├── produced: int            (net = production - maintenance)
  ├── wasCapped: bool
  ├── beforeAmount: int
  └── afterAmount: int

TurnResult (immutable)
  ├── changes: List<TurnResourceChange>
  ├── previousTurn: int
  ├── newTurn: int
  └── hadRecruitedUnits: bool

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
  ├── Compute net production (production - maintenance)
  ├── Show TurnConfirmationDialog (before → predicted progression)
  │     ├── Cancel → abort (game untouched)
  │     └── Confirm ↓
  │
  ├── TurnResolver.resolve(game)
  │     ├── Snapshot before-values for each resource
  │     ├── ProductionCalculator.fromBuildings() → production map
  │     ├── MaintenanceCalculator.fromUnits() → maintenance map
  │     ├── For each resource: net = production - maintenance
  │     ├── amount += net (clamped to [0, maxStorage])
  │     ├── Track wasCapped, beforeAmount, afterAmount
  │     ├── Record hadRecruitedUnits flag
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
| `showTurnConfirmationDialog()` | Pre-turn: shows `before (+net) → predicted` per resource, capped lines in orange with "(MAX)" |
| `showTurnSummaryDialog()` | Post-turn: shows `before (+net) → after` per resource, plus "Recrutement disponible" if units were recruited last turn |

Both are top-level functions returning dialog results. Private `StatelessWidget` classes handle the UI.

### Visual Indicators

- **Capped resources**: orange text + "(MAX)" suffix
- **Negative net production**: red text (maintenance exceeds production)
- **Zero net production**: dimmed text

## Design Decisions

1. **TurnResolver is stateless** — Instantiated per call, easy to test, no lifecycle.
2. **Immutable result objects** — `TurnResult` carries before/after feedback for the summary dialog without coupling domain to UI.
3. **Net production** — `produced` field in `TurnResourceChange` represents net production (production - maintenance), keeping the model simple.
4. **MaintenanceCalculator is separate** — Delegates to `UnitCostCalculator.maintenanceCost()`, keeping single responsibility.
5. **Floor at zero** — Resources cannot go negative; if maintenance exceeds production + current amount, the amount is floored at 0.
6. **Async flow in GameScreen** — `_nextTurn()` is async, chaining confirm → resolve → save → summary with `mounted` guards.

## File Structure

```
lib/domain/
  ├── turn_result.dart            # TurnResourceChange + TurnResult
  ├── turn_resolver.dart          # Stateless resolver
  └── maintenance_calculator.dart # Army maintenance costs
lib/presentation/widgets/
  ├── turn_confirmation_dialog.dart
  └── turn_summary_dialog.dart
test/domain/
  ├── turn_resolver_test.dart
  └── maintenance_calculator_test.dart
test/presentation/widgets/
  ├── turn_confirmation_dialog_test.dart
  └── turn_summary_dialog_test.dart
test/presentation/screens/
  └── game_screen_turn_test.dart   # Turn flow integration tests
```

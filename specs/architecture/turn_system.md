# Turn System — Architecture

## Overview

The turn system resolves a full game turn when the player presses "Next Turn": confirmation dialog, resource production with storage capping, auto-save, and post-turn summary.

## Domain Model

```
TurnResourceChange (immutable)
  ├── type: ResourceType
  ├── produced: int
  └── wasCapped: bool

TurnResult (immutable)
  └── changes: List<TurnResourceChange>

TurnResolver (stateless)
  └── resolve(Game) → TurnResult
        Computes production → applies to resources → caps at maxStorage → increments turn
```

## Turn Resolution Flow

```
Player taps "Tour suivant"
  │
  ├── Show TurnConfirmationDialog (production preview)
  │     ├── Cancel → abort (game untouched)
  │     └── Confirm ↓
  │
  ├── TurnResolver.resolve(game)
  │     ├── ProductionCalculator.fromBuildings() → production map
  │     ├── For each resource: amount += produced, cap at maxStorage
  │     ├── Track wasCapped per resource
  │     └── game.turn++
  │
  ├── GameRepository.save(game)   ← auto-save
  │
  ├── setState() → UI refreshes with new values
  │
  └── Show TurnSummaryDialog (gains + capping indicators)
```

## Presentation

| Widget | Role |
|--------|------|
| `showTurnConfirmationDialog()` | Pre-turn: shows expected production per resource |
| `showTurnSummaryDialog()` | Post-turn: shows actual gains with "(max atteint)" if capped |

Both are top-level functions returning dialog results. Private `StatelessWidget` classes handle the UI.

## Design Decisions

1. **TurnResolver is stateless** — Instantiated per call, easy to test, no lifecycle.
2. **Immutable result objects** — `TurnResult` carries feedback for the summary dialog without coupling domain to UI.
3. **Production reuse** — Uses existing `ProductionCalculator`, no duplication.
4. **Mutation in place** — Consistent with `UpgradeBuildingAction` pattern; `Game` is mutable.
5. **Async flow in GameScreen** — `_nextTurn()` is async, chaining confirm → resolve → save → summary with `mounted` guards.

## File Structure

```
lib/domain/
  ├── turn_result.dart          # TurnResourceChange + TurnResult
  └── turn_resolver.dart        # Stateless resolver
lib/presentation/widgets/
  ├── turn_confirmation_dialog.dart
  └── turn_summary_dialog.dart
test/domain/
  └── turn_resolver_test.dart
test/presentation/widgets/
  ├── turn_confirmation_dialog_test.dart
  └── turn_summary_dialog_test.dart
```

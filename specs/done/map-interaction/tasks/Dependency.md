# Dependency Graph — Map Interaction

## Layer 1: Domain Models (no dependencies)

```
[01] ExplorationOrder model
[03] RevealAreaCalculator
[05] CellEligibilityChecker
```

Tasks 01, 03, 05 are independent and can be executed in parallel.

## Layer 2: Game State + Tests

```
[02] Game model + Hive adapter  ← depends on [01]
[04] RevealAreaCalculator tests ← depends on [03]
[06] CellEligibility tests     ← depends on [05]
```

Tasks 02, 04, 06 can be executed in parallel (each depends on a different Layer 1 task).

## Layer 3: Actions + Turn Resolution

```
[07] ExploreAction              ← depends on [01], [02], [05]
[09] Turn resolution exploration ← depends on [01], [02], [03]
```

Tasks 07 and 09 can be executed in parallel.

## Layer 4: Action Tests + UI Foundation

```
[08] ExploreAction tests         ← depends on [07]
[10] Turn resolution tests       ← depends on [09]
[11] Cell tap handler (UI)       ← no domain dependency
[12] Exploration bottom sheet    ← depends on [03] (for display)
```

Tasks 08, 10, 11, 12 can be executed in parallel.

## Layer 5: UI Integration

```
[13] Wire exploration in game screen ← depends on [07], [11], [12]
[14] Pending exploration marker      ← depends on [02], [11]
[15] Turn confirmation exploration   ← depends on [02]
[16] Turn summary exploration        ← depends on [09]
```

Tasks 13, 14, 15, 16 can be largely parallelized (each has different dependencies).

## Execution Order Summary

```
                  ┌──────┐   ┌──────┐   ┌──────┐
  Layer 1:        │  01  │   │  03  │   │  05  │
                  └──┬───┘   └──┬───┘   └──┬───┘
                     │          │           │
                  ┌──▼───┐   ┌──▼───┐   ┌──▼───┐
  Layer 2:        │  02  │   │  04  │   │  06  │
                  └──┬───┘   └──┬───┘   └──┬───┘
                     │          │           │
               ┌─────┴──┬──────┘     ┌─────┘
               │        │            │
            ┌──▼───┐ ┌──▼───┐       │
  Layer 3:  │  07  │ │  09  │       │
            └──┬───┘ └──┬───┘       │
               │        │           │
  Layer 4:  ┌──▼───┐ ┌──▼───┐ ┌────▼─┐  ┌──────┐
            │  08  │ │  10  │ │  11  │  │  12  │
            └──┬───┘ └──┬───┘ └──┬───┘  └──┬───┘
               │        │        │          │
  Layer 5:  ┌──┴────────┴────┐   │   ┌─────┘
            │    ┌──────┐    │   │   │
            │    │  16  │    │ ┌─▼───▼─┐  ┌──────┐  ┌──────┐
            │    └──────┘    │ │  13   │  │  14  │  │  15  │
            │                │ └───────┘  └──────┘  └──────┘
            └────────────────┘
```

## Critical Path

`01 → 02 → 07 → 13` (model → game state → action → UI wiring)

This is the minimum sequence to get the core feature working end-to-end.

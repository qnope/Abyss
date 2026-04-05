# Screens

`lib/presentation/screens/` — Full-page views organized into `game/` and `menu/` subfolders.

## Menu Screens

| Screen | Role |
|--------|------|
| `MainMenuScreen` | Entry point. Two buttons: new game, load game. Receives `GameRepository`. |
| `NewGameScreen` | Player name input and starter kit selection. Creates a `Game` and navigates to `GameScreen`. |
| `LoadGameScreen` | Lists saved games from `GameRepository`. Tap to resume. |

## Game Screen

`GameScreen` is the main gameplay view. It holds a `Game` and `GameRepository`.

### Layout

```
┌──────────────────────┐
│     ResourceBar      │  ← always visible, shows 5 resources + net production
├──────────────────────┤
│                      │
│   Tab Content Area   │  ← switches between 4 tabs
│                      │
├──────────────────────┤
│    GameBottomBar     │  ← tab navigation + "Next Turn" button
└──────────────────────┘
```

### Tabs

| Index | Content | Widget |
|-------|---------|--------|
| 0 | Buildings | `BuildingListView` |
| 1 | Map | `GameMapView` (generated on first visit) |
| 2 | Army | `ArmyListView` |
| 3 | Tech | `TechTreeView` |

### Helper Files

GameScreen logic is split into helper files to stay under 150 lines:

| File | Responsibility |
|------|---------------|
| `game_screen_actions.dart` | `showBuildingDetailAction`, `showUnitDetailAction` — wire domain actions to bottom sheets |
| `game_screen_exploration.dart` | `buildMapTab`, `_showExplorationAction` — map tap → bottom sheet → ExploreAction flow |
| `game_screen_tech_actions.dart` | `showBranchDetail`, `showNodeDetail` — tech tree interactions |
| `game_screen_turn_helpers.dart` | `computeConsumption`, `computeBuildingsToDeactivate`, `computeUnitsToLose` — pre-turn calculations |

### Exploration Flow

1. Player taps a map cell
2. `showExplorationAction` checks eligibility and scout count
3. `ExplorationSheet` shows target info, cost, and reveal area
4. On confirm: `ExploreAction` consumes 1 scout, queues `ExplorationOrder`
5. Pending cells show a cyan border marker on the map

### Turn Flow

1. Player taps "Next Turn"
2. Pre-turn calculations compute what will happen
3. `TurnConfirmationDialog` shows preview (deactivations, losses, pending explorations)
4. On confirm: `TurnResolver().resolve(game)` mutates game state (includes exploration resolution)
5. Game is saved, UI rebuilds
6. `TurnSummaryDialog` shows results (includes exploration outcomes)

# Widgets

`lib/presentation/widgets/` — Reusable UI components organized by domain module, grouped by the domain they render.

## Building Widgets (`building/`)

| Widget | Purpose |
|--------|---------|
| `BuildingCard` | Displays a building with level, status, and production info |
| `BuildingListView` | Scrollable list of all buildings |
| `BuildingDetailSheet` | Bottom sheet with stats and upgrade button |
| `BuildingIcon` | SVG icon for a building type |
| `UpgradeSection` | Cost breakdown and upgrade controls |

## Unit Widgets (`unit/`)

| Widget | Purpose |
|--------|---------|
| `UnitCard` | Displays unit type with count and stats |
| `ArmyListView` | Grid of all unit types |
| `UnitDetailSheet` | Bottom sheet with recruitment controls |
| `UnitIcon` | SVG icon for a unit type |
| `RecruitmentSection` | Quantity selector and cost display |

## Resource Widgets (`resource/`)

| Widget | Purpose |
|--------|---------|
| `ResourceBar` | Top bar showing all 5 resources with net production |
| `ResourceBarItem` | Two-line layout: icon + amount on line 1, rate text on line 2 |
| `ResourceDetailSheet` | Bottom sheet with resource breakdown |
| `ResourceIcon` | SVG icon for a resource type |
| `AnimatedResourceAmount` | Smooth number transition on value change |
| `ResourceGainDialog` | Modal dialog showing a list of resources gained (icon + `+amount`) after collecting a treasure or ruins. Shows an empty message when all deltas are zero |

## Tech Widgets (`tech/`)

| Widget | Purpose |
|--------|---------|
| `TechTreeView` | Displays all 3 tech branches with nodes |
| `TechNodeWidget` | Single tech node with completion state |
| `TechBranchDetailSheet` | Branch info and unlock controls |
| `TechNodeDetailSheet` | Research cost and prerequisites |

## Map Widgets (`map/`)

| Widget | Purpose |
|--------|---------|
| `GameMapView` | Renders the 20x20 grid with fog of war, tap callbacks, pending markers. Zoom: 1 cell (max) → 8 cells (default) → full map (min) |
| `MapCellWidget` | Single cell with terrain, content rendering, tap handler, and exploration marker. Greys out collected treasures and ruins |
| `ExplorationSheet` | Bottom sheet for confirming scout exploration (cost, reveal area, eligibility) |
| `TreasureSheet` | Bottom sheet for collecting a `resourceBonus` or `ruins` cell (free, immediate). Triggers `CollectTreasureAction`; on success, `game_screen_map_actions.dart` closes the sheet and opens a `ResourceGainDialog` with the per-resource deltas from the returned `CollectTreasureResult` |
| `MonsterLairSheet` | Bottom sheet showing monster difficulty, unit count, and monster stats. Exposes a **"Préparer le combat"** button that pops the sheet and fires the `onPrepareFight` callback (wired by `game_screen_map_actions.dart` to `openArmySelection` in `game_screen_fight_actions.dart`) |
| `CellInfoSheet` | Generic info bottom sheet for empty plains, the player base, and already-collected cells |

## Fight Widgets (`fight/`)

| Widget | Purpose |
|--------|---------|
| `UnitQuantityRow` | One row of the army-selection list: unit icon, name + current stock, minus/value/plus controls, and an embedded `Slider` synchronized with the `+/-` buttons to pick how many to commit to the fight |
| `SelectionSummaryCard` | Reusable card showing the total ATK/DEF of a selection plus the active military bonus label |
| `MonsterPreview` | Card showing the lair's SVG, difficulty label, level, unit count, and per-monster HP/ATK/DEF chips. Reused by the army-selection and fight-summary screens |
| `FightTurnList` | Vertical list of per-turn summary tiles (alive counts, HP, damage dealt/received, crit badge). Feeds from `FightResult.turnSummaries` |

## Turn Widgets (`turn/`)

| Widget | Purpose |
|--------|---------|
| `TurnConfirmationDialog` | Preview of turn effects before confirming (includes pending explorations) |
| `TurnSummaryDialog` | Results after turn resolution (includes exploration results) |
| `ExplorationSummarySection` | Exploration results section extracted from turn summary |

## Common Widgets (`common/`)

| Widget | Purpose |
|--------|---------|
| `GameBottomBar` | Tab navigation + turn button |
| `SettingsDialog` | Save/quit game settings |
| `SavedGameCard` | Card for saved game in load screen |
| `TabPlaceholder` | Placeholder for empty tab content |

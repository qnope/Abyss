# Widgets

`lib/presentation/widgets/` — Reusable UI components organized by domain module. 31 widget files across 7 categories.

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
| `GameMapView` | Renders the 20x20 grid with fog of war, tap callbacks, and pending markers |
| `MapCellWidget` | Single cell with terrain, content rendering, tap handler, and exploration marker |
| `ExplorationSheet` | Bottom sheet for confirming scout exploration (cost, reveal area, eligibility) |

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

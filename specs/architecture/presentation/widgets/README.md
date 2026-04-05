# Widgets

`lib/presentation/widgets/` — Reusable UI components organized by domain module. 28 widget files across 7 categories.

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
| `ResourceBarItem` | Single resource amount + production delta |
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
| `GameMapView` | Renders the 20x20 grid with fog of war |
| `MapCellWidget` | Single cell with terrain and content rendering |

## Turn Widgets (`turn/`)

| Widget | Purpose |
|--------|---------|
| `TurnConfirmationDialog` | Preview of turn effects before confirming |
| `TurnSummaryDialog` | Results after turn resolution |

## Common Widgets (`common/`)

| Widget | Purpose |
|--------|---------|
| `GameBottomBar` | Tab navigation + turn button |
| `SettingsDialog` | Save/quit game settings |
| `SavedGameCard` | Card for saved game in load screen |
| `TabPlaceholder` | Placeholder for empty tab content |

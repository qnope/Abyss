# Game Screen — Architecture

## Overview

The main gameplay screen with three zones: resource bar (top), tab content (center), and bottom bar (navigation + actions).

## Layout

```
┌──────────────────────────────────┐
│  ResourceBar                     │  ← SafeArea, semi-transparent black
│  🌿100 +10/t  🪸80  ⛏50 ⚡60 │ 💎5│
├──────────────────────────────────┤
│                                  │
│         Tab Content              │  ← Expanded, switches by tab index
│   (Base=BuildingListView, rest=placeholders) │
│                                  │
├──────────────────────────────────┤
│  ⚙️ Settings  │ Tour 5 │ ▶ Next │  ← Action row
│  Base  Carte  Armée  Tech        │  ← BottomNavigationBar
└──────────────────────────────────┘
```

## Widget Tree

```
GameScreen (StatefulWidget)
  └── Scaffold
        ├── body: Column
        │     ├── ResourceBar
        │     │     ├── ResourceBarItem × 4 (production)
        │     │     ├── Divider
        │     │     └── ResourceBarItem (pearl)
        │     └── Expanded → tab content (BuildingListView | TabPlaceholder)
        └── bottomNavigationBar: GameBottomBar
              ├── Action row (settings, turn counter, next turn)
              └── BottomNavigationBar (4 tabs)
```

## Production

Production per turn is computed dynamically via `ProductionCalculator.fromBuildings()` on every `build()`. The result is passed down as `Map<ResourceType, int>` through `ResourceBar` → `ResourceBarItem` / `ResourceDetailSheet`.

## State Management

- `_currentTab` (int) — local state in `_GameScreenState`
- `game` — mutated by `TurnResolver` and `ActionExecutor`, triggers `setState`
- No state management library needed yet — all state is local

## Interactions

| Action | Handler | Effect |
|--------|---------|--------|
| Tap resource | `showResourceDetailSheet()` | Opens modal bottom sheet |
| Tap building | `_showBuildingDetail()` | Opens BuildingDetailSheet |
| Upgrade building | `_upgradeBuilding()` | Via `ActionExecutor` + `UpgradeBuildingAction` |
| Tap tab | `onTabChanged` | Switches `_currentTab` |
| Next Turn | `_nextTurn()` | Confirm → resolve → save → summary (see [turn_system.md](turn_system.md)) |
| Settings | `_showSettings()` | Opens dialog → save & quit |

## Design Decisions

1. **No AppBar** — ResourceBar replaces it, using SafeArea for notch/status bar.
2. **StatefulWidget** — Minimal local state (tab index). No need for Provider/Bloc yet.
3. **Callbacks up, data down** — GameBottomBar and ResourceBar are pure presentation widgets with callbacks.
4. **AnimatedResourceAmount** — Color flash (green/red, 500ms) on value change, ready for when production is wired up.

## File Structure

```
lib/presentation/
  ├── screens/
  │     └── game_screen.dart
  ├── widgets/
  │     ├── resource_bar.dart
  │     ├── resource_bar_item.dart
  │     ├── resource_detail_sheet.dart
  │     ├── game_bottom_bar.dart
  │     ├── tab_placeholder.dart
  │     ├── animated_resource_amount.dart
  │     ├── building_icon.dart
  │     ├── building_card.dart
  │     ├── building_list_view.dart
  │     ├── building_detail_sheet.dart
  │     ├── upgrade_section.dart
  │     ├── turn_confirmation_dialog.dart
  │     └── turn_summary_dialog.dart
  └── extensions/
        ├── resource_type_extensions.dart
        └── building_type_extensions.dart
```

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
│       (placeholder for now)      │
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
        │     └── Expanded → TabPlaceholder
        └── bottomNavigationBar: GameBottomBar
              ├── Action row (settings, turn counter, next turn)
              └── BottomNavigationBar (4 tabs)
```

## State Management

- `_currentTab` (int) — local state in `_GameScreenState`
- `game.turn` — mutated directly via `game.turn++`, triggers `setState`
- No state management library needed yet — all state is local

## Interactions

| Action | Handler | Effect |
|--------|---------|--------|
| Tap resource | `showResourceDetailSheet()` | Opens modal bottom sheet |
| Tap tab | `onTabChanged` | Switches `_currentTab` |
| Next Turn | `_nextTurn()` | Increments `game.turn` |
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
  │     └── animated_resource_amount.dart
  └── extensions/
        └── resource_type_extensions.dart
```

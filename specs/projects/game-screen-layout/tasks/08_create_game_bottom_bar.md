# Task 08: Create GameBottomBar widget

## Summary

Create a bottom bar with 4 navigation tabs (Base, Map, Army, Tech), a turn number display, a prominent "Next Turn" button, and a settings icon for save/quit.

## Implementation Steps

### Step 1: Create `lib/presentation/widgets/game_bottom_bar.dart`

```dart
import 'package:flutter/material.dart';
import '../theme/abyss_colors.dart';

class GameBottomBar extends StatelessWidget {
  final int currentTab;
  final int turnNumber;
  final ValueChanged<int> onTabChanged;
  final VoidCallback onNextTurn;
  final VoidCallback onSettings;

  const GameBottomBar({
    super.key,
    required this.currentTab,
    required this.turnNumber,
    required this.onTabChanged,
    required this.onNextTurn,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildActionRow(),
        _buildTabBar(),
      ],
    );
  }

  Widget _buildActionRow() {
    return Container(
      color: AbyssColors.deepNavy,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.settings, color: AbyssColors.onSurfaceDim),
            onPressed: onSettings,
            tooltip: 'Paramètres',
          ),
          const Spacer(),
          Text(
            'Tour $turnNumber',
            style: const TextStyle(
              color: AbyssColors.biolumCyan,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              letterSpacing: 1.2,
            ),
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: onNextTurn,
            icon: const Icon(Icons.skip_next, size: 20),
            label: const Text('Tour suivant'),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return BottomNavigationBar(
      currentIndex: currentTab,
      onTap: onTabChanged,
      type: BottomNavigationBarType.fixed,
      backgroundColor: AbyssColors.abyssBlack,
      selectedItemColor: AbyssColors.biolumCyan,
      unselectedItemColor: AbyssColors.onSurfaceDim,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Base'),
        BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Carte'),
        BottomNavigationBarItem(icon: Icon(Icons.shield), label: 'Armée'),
        BottomNavigationBarItem(icon: Icon(Icons.science), label: 'Tech'),
      ],
    );
  }
}
```

### Key Design Decisions

- **Layout:** A `Column` with two rows:
  1. Action row: settings icon (left) + turn number (center) + "Next Turn" button (right).
  2. Standard `BottomNavigationBar` with 4 tabs.
- **Settings icon** in bottom bar (per user choice) — triggers save/quit flow.
- **Turn number** displayed prominently between settings and next turn.
- **"Tour suivant"** uses the existing `ElevatedButton` theme (cyan, prominent).
- Tab labels in French: Base, Carte, Armée, Tech.

## Dependencies

- None (pure presentation widget with callbacks).

## Test Plan

- **File:** `test/presentation/widgets/game_bottom_bar_test.dart` (Task 12)
- Test: Renders 4 tabs with correct labels.
- Test: Displays turn number.
- Test: Tab tap triggers onTabChanged with correct index.
- Test: Next Turn button triggers onNextTurn.
- Test: Settings icon triggers onSettings.

## Notes

- The `BottomNavigationBar` uses `fixed` type to show all labels.
- Selected tab uses `biolumCyan` for the highlighted/glow effect.
- File should stay well under 150 lines.

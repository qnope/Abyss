# Task 21: Create LevelSelector Widget

## Summary
Create a tab-like widget for switching between depth levels, displayed at the top of the map tab. Locked levels are grayed out. Active level highlighted in `biolumCyan`.

## Implementation Steps

1. **Create LevelSelector** in `lib/presentation/widgets/map/level_selector.dart`:
   ```dart
   class LevelSelector extends StatelessWidget {
     final int currentLevel;
     final Set<int> unlockedLevels;       // levels with maps
     final Map<int, int> capturedCounts;   // level → captured faille count
     final ValueChanged<int> onLevelSelected;
   }
   ```

2. **Layout**: Horizontal row of 3 level chips:
   - `[Niv 1: Surface]  [Niv 2: Profondeurs]  [Niv 3: Noyau]`
   - Active level: `biolumCyan` background, white text
   - Unlocked but inactive: `surfaceDark` background, `biolumCyan` text
   - Locked: `surfaceDarker` background, gray text, padlock icon

3. **Captured count indicator**: small badge on each chip showing number of captured failles on that level (e.g., "2/4")

4. **Tap handler**: `onLevelSelected(level)` — only fires for unlocked levels

5. **Use AbyssTheme** for all styling (colors, text styles, border radius)

## Dependencies
- **Internal**: None (standalone widget)
- **External**: AbyssTheme (existing)

## Test Plan
- **File**: `test/presentation/widgets/map/level_selector_test.dart`
  - Verify 3 level chips rendered
  - Verify active level has `biolumCyan` styling
  - Verify locked levels show padlock and are not tappable
  - Verify `onLevelSelected` callback fires on tap
  - Verify captured count badge displays correctly
- Run `flutter analyze`

## Notes
- Keep under 150 lines. The widget is purely presentational — no domain logic.
- Level names in French: "Surface", "Profondeurs", "Noyau".

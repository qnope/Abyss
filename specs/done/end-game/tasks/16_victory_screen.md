# Task 16: Create victory screen

## Summary

Create the victory screen that displays game statistics and offers the player to continue playing or return to the menu.

## Implementation Steps

### 1. Create `lib/presentation/screens/game/victory_screen.dart`

```dart
class VictoryScreen extends StatelessWidget {
  final GameStatistics statistics;
  final VoidCallback onContinue;
  final VoidCallback onReturnToMenu;

  const VictoryScreen({
    super.key,
    required this.statistics,
    required this.onContinue,
    required this.onReturnToMenu,
  });
}
```

Layout:
- Center-aligned column
- Volcanic kernel SVG icon (large, 96px)
- "VICTOIRE !" title in headline style with gold/warning color
- Subtitle: "Vous avez conquis le Noyau Volcanique !"
- Divider
- Statistics card with 4 rows:
  - "Tours joues: {turnsPlayed}" with Icons.timer
  - "Monstres vaincus: {monstersDefeated}" with Icons.dangerous
  - "Bases capturees: {basesCaptured}" with Icons.flag
  - "Ressources collectees: {totalResourcesCollected}" with Icons.inventory
- Spacer
- Two buttons:
  - Primary: "Continuer en mode libre" → calls `onContinue`
  - Secondary: "Retour au menu" → calls `onReturnToMenu`

### 2. Style

Use the existing theme from `lib/presentation/theme/`:
- Background: default scaffold
- Title color: `AbyssColors.warning` (gold/orange)
- Stats use `AbyssColors.onSurface`
- Primary button: standard elevated
- Secondary button: outlined

## Dependencies

- Task 13: `GameStatistics` data class

## Test Plan

- **File**: `test/presentation/screens/game/victory_screen_test.dart`
- Test: displays "VICTOIRE !" title
- Test: displays all 4 statistics with correct values
- Test: "Continuer" button calls `onContinue`
- Test: "Retour au menu" button calls `onReturnToMenu`
- Test: volcanic kernel icon is displayed

## Notes

- The screen is presented as a full-screen route (not a dialog), matching the significance of winning the game
- The same layout could be adapted for a defeat screen in the future (US-5), but that's not implemented yet
- Keep under 150 lines per CLAUDE.md rules

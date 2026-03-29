# Task 09: Create TabPlaceholder widget

## Summary

Create a simple placeholder widget for each tab (Base, Map, Army, Tech) that shows a centered icon and "Section — Coming soon" text.

## Implementation Steps

### Step 1: Create `lib/presentation/widgets/tab_placeholder.dart`

```dart
import 'package:flutter/material.dart';
import '../theme/abyss_colors.dart';

class TabPlaceholder extends StatelessWidget {
  final IconData icon;
  final String label;

  const TabPlaceholder({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: AbyssColors.biolumCyan.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(
            label,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AbyssColors.onSurfaceDim,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bientôt disponible',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AbyssColors.disabled,
            ),
          ),
        ],
      ),
    );
  }
}
```

## Dependencies

- None (standalone widget).

## Test Plan

- Minimal — this is a simple display widget.
- Verified visually in the GameScreen integration.

## Notes

- Used with these configurations in GameScreen:
  - `TabPlaceholder(icon: Icons.home, label: 'Base')`
  - `TabPlaceholder(icon: Icons.map, label: 'Carte')`
  - `TabPlaceholder(icon: Icons.shield, label: 'Armée')`
  - `TabPlaceholder(icon: Icons.science, label: 'Tech')`
- File is intentionally very short (~35 lines).

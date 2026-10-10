import 'package:flutter/material.dart';
import '../../theme/abyss_colors.dart';
import 'map_level_info.dart';

/// Horizontal row of level chips for switching between map depths.
///
/// Purely presentational — no domain logic. The parent owns the
/// [currentLevel] and reacts to [onLevelSelected].
class LevelSelector extends StatelessWidget {
  const LevelSelector({
    super.key,
    required this.currentLevel,
    required this.unlockedLevels,
    required this.onLevelSelected,
  });

  final int currentLevel;
  final Set<int> unlockedLevels;
  final ValueChanged<int> onLevelSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final level in MapLevelInfo.levels)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _LevelChip(
                label: 'Niv $level: ${MapLevelInfo.nameOf(level)}',
                isActive: level == currentLevel,
                isUnlocked: unlockedLevels.contains(level),
                onTap: () => onLevelSelected(level),
              ),
            ),
        ],
      ),
    );
  }
}

class _LevelChip extends StatelessWidget {
  const _LevelChip({
    required this.label,
    required this.isActive,
    required this.isUnlocked,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final bool isUnlocked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = _colors();

    return GestureDetector(
      onTap: isUnlocked ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isUnlocked)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(Icons.lock, size: 14, color: fg),
              ),
            Text(
              label,
              style: TextStyle(
                color: fg,
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  (Color, Color) _colors() {
    if (isActive) {
      return (AbyssColors.biolumCyan, Colors.white);
    }
    if (isUnlocked) {
      return (AbyssColors.surfaceDim, AbyssColors.biolumCyan);
    }
    return (AbyssColors.trench, AbyssColors.disabled);
  }
}

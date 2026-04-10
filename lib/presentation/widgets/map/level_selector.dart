import 'package:flutter/material.dart';
import '../../theme/abyss_colors.dart';

/// Data for a single level chip.
class _LevelInfo {
  const _LevelInfo(this.level, this.label);
  final int level;
  final String label;
}

const _levels = [
  _LevelInfo(1, 'Niv 1: Surface'),
  _LevelInfo(2, 'Niv 2: Profondeurs'),
  _LevelInfo(3, 'Niv 3: Noyau'),
];

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
          for (final info in _levels)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _LevelChip(
                info: info,
                isActive: info.level == currentLevel,
                isUnlocked: unlockedLevels.contains(info.level),
                onTap: () => onLevelSelected(info.level),
              ),
            ),
        ],
      ),
    );
  }
}

class _LevelChip extends StatelessWidget {
  const _LevelChip({
    required this.info,
    required this.isActive,
    required this.isUnlocked,
    required this.onTap,
  });

  final _LevelInfo info;
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
              info.label,
              style: TextStyle(
                color: fg,
                fontSize: 13,
                fontWeight:
                    isActive ? FontWeight.w600 : FontWeight.w400,
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

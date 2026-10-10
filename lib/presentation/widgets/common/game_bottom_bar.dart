import 'package:flutter/material.dart';
import '../../../domain/objective/guide/guide_area.dart';
import '../../theme/abyss_colors.dart';
import '../guide/guide_halo.dart';
import '../guide/guide_scope.dart';

class GameBottomBar extends StatelessWidget {
  /// Area of the game screen each tab opens, in the order of the tabs.
  static const tabAreas = [
    GuideArea.base,
    GuideArea.map,
    GuideArea.army,
    GuideArea.research,
  ];

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
    final guide = GuideScope.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildActionRow(guide?.endTurn ?? false),
        _buildTabBar(guide?.area),
      ],
    );
  }

  Widget _buildActionRow(bool endTurnGuided) {
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
          GuideHalo(
            active: endTurnGuided,
            child: ElevatedButton.icon(
              onPressed: onNextTurn,
              icon: const Icon(Icons.skip_next, size: 20),
              label: const Text('Tour suivant'),
            ),
          ),
        ],
      ),
    );
  }

  /// The tabs; the halo surrounds the one opening [guided], unless open.
  Widget _buildTabBar(GuideArea? guided) {
    BottomNavigationBarItem tab(int index, IconData icon, String label) =>
        BottomNavigationBarItem(
          icon: GuideHalo(
            active: index != currentTab && tabAreas[index] == guided,
            shape: BoxShape.circle,
            child: Icon(icon),
          ),
          label: label,
        );

    return BottomNavigationBar(
      currentIndex: currentTab,
      onTap: onTabChanged,
      type: BottomNavigationBarType.fixed,
      backgroundColor: AbyssColors.abyssBlack,
      selectedItemColor: AbyssColors.biolumCyan,
      unselectedItemColor: AbyssColors.onSurfaceDim,
      items: [
        tab(0, Icons.home, 'Base'),
        tab(1, Icons.map, 'Carte'),
        tab(2, Icons.shield, 'Armée'),
        tab(3, Icons.science, 'Tech'),
      ],
    );
  }
}

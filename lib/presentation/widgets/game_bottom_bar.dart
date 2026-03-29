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

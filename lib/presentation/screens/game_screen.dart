import 'package:flutter/material.dart';
import '../../data/game_repository.dart';
import '../../domain/game.dart';
import '../widgets/game_bottom_bar.dart';
import '../widgets/resource_bar.dart';
import '../widgets/tab_placeholder.dart';
import 'main_menu_screen.dart';

class GameScreen extends StatefulWidget {
  final Game game;
  final GameRepository repository;

  const GameScreen({
    super.key,
    required this.game,
    required this.repository,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int _currentTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ResourceBar(resources: widget.game.resources),
          Expanded(child: _buildTabContent()),
        ],
      ),
      bottomNavigationBar: GameBottomBar(
        currentTab: _currentTab,
        turnNumber: widget.game.turn,
        onTabChanged: (index) => setState(() => _currentTab = index),
        onNextTurn: _nextTurn,
        onSettings: _showSettings,
      ),
    );
  }

  Widget _buildTabContent() {
    return switch (_currentTab) {
      0 => const TabPlaceholder(icon: Icons.home, label: 'Base'),
      1 => const TabPlaceholder(icon: Icons.map, label: 'Carte'),
      2 => const TabPlaceholder(icon: Icons.shield, label: 'Armee'),
      3 => const TabPlaceholder(icon: Icons.science, label: 'Tech'),
      _ => const SizedBox.shrink(),
    };
  }

  void _nextTurn() {
    setState(() {
      widget.game.turn++;
    });
  }

  void _showSettings() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Parametres'),
        content: const Text('Que souhaitez-vous faire ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _saveAndQuit();
            },
            child: const Text('Sauvegarder et quitter'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveAndQuit() async {
    await widget.repository.save(widget.game);
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => MainMenuScreen(repository: widget.repository),
      ),
      (_) => false,
    );
  }
}

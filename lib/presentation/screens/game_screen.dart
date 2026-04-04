import 'package:flutter/material.dart';
import '../../data/game_repository.dart';
import '../../domain/building.dart';
import '../../domain/action_executor.dart';
import '../../domain/upgrade_building_action.dart';
import '../../domain/game.dart';
import '../../domain/production_calculator.dart';
import '../../domain/turn_resolver.dart';
import '../widgets/building_detail_sheet.dart';
import '../widgets/turn_confirmation_dialog.dart';
import '../widgets/turn_summary_dialog.dart';
import '../widgets/building_list_view.dart';
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
    final production = ProductionCalculator.fromBuildings(widget.game.buildings);
    return Scaffold(
      body: Column(
        children: [
          ResourceBar(resources: widget.game.resources, production: production),
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
      0 => BuildingListView(
        buildings: widget.game.buildings,
        resources: widget.game.resources,
        onBuildingTap: _showBuildingDetail,
      ),
      1 => const TabPlaceholder(icon: Icons.map, label: 'Carte'),
      2 => const TabPlaceholder(icon: Icons.shield, label: 'Armee'),
      3 => const TabPlaceholder(icon: Icons.science, label: 'Tech'),
      _ => const SizedBox.shrink(),
    };
  }

  void _showBuildingDetail(Building building) {
    showBuildingDetailSheet(
      context,
      building: building,
      resources: widget.game.resources,
      allBuildings: widget.game.buildings,
      onUpgrade: () => _upgradeBuilding(building),
    );
  }

  void _upgradeBuilding(Building building) {
    final action = UpgradeBuildingAction(buildingType: building.type);
    final result = ActionExecutor().execute(action, widget.game);
    if (result.isSuccess) {
      setState(() {});
      Navigator.pop(context);
    }
  }

  Future<void> _nextTurn() async {
    final production = ProductionCalculator.fromBuildings(
      widget.game.buildings,
    );

    final confirmed = await showTurnConfirmationDialog(
      context,
      production: production,
    );
    if (!confirmed || !mounted) return;

    final result = TurnResolver().resolve(widget.game);

    await widget.repository.save(widget.game);

    setState(() {});

    if (!mounted) return;
    await showTurnSummaryDialog(context, result: result);
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

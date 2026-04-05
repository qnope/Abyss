import 'package:flutter/material.dart';
import '../../../data/game_repository.dart';
import '../../../domain/building/building_type.dart';
import '../../../domain/game/game.dart';
import '../../../domain/resource/production_calculator.dart';
import '../../../domain/turn/turn_resolver.dart';
import '../../widgets/unit/army_list_view.dart';
import '../../widgets/turn/turn_confirmation_dialog.dart';
import '../../widgets/turn/turn_summary_dialog.dart';
import '../../widgets/building/building_list_view.dart';
import '../../widgets/common/game_bottom_bar.dart';
import '../../widgets/resource/resource_bar.dart';
import '../../widgets/common/settings_dialog.dart';
import '../../widgets/tech/tech_tree_view.dart';
import 'game_screen_actions.dart';
import 'game_screen_exploration.dart';
import 'game_screen_tech_actions.dart';
import 'game_screen_turn_helpers.dart';
import '../menu/main_menu_screen.dart';

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
    final production = ProductionCalculator.fromBuildings(
      widget.game.buildings,
      techBranches: widget.game.techBranches,
    );
    final consumption = computeConsumption(widget.game);
    return Scaffold(
      body: Column(
        children: [
          ResourceBar(
            resources: widget.game.resources,
            production: production,
            consumption: consumption,
          ),
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
    final g = widget.game;
    return switch (_currentTab) {
      0 => BuildingListView(
        buildings: g.buildings,
        resources: g.resources,
        onBuildingTap: (b) => showBuildingDetailAction(
          context, g, b, () => setState(() {})),
      ),
      1 => buildMapTab(
        context, g, widget.repository, () => setState(() {})),
      2 => ArmyListView(
        units: g.units,
        barracksLevel: g.buildings[BuildingType.barracks]!.level,
        onUnitTap: (t) => showUnitDetailAction(
          context, g, t, () => setState(() {})),
      ),
      3 => TechTreeView(
        techBranches: g.techBranches,
        buildings: g.buildings,
        resources: g.resources,
        onBranchTap: (branch) => showBranchDetail(
          context, g, branch, () => setState(() {})),
        onNodeTap: (branch, level) => showNodeDetail(
          context, g, branch, level, () => setState(() {})),
      ),
      _ => const SizedBox.shrink(),
    };
  }

  Future<void> _nextTurn() async {
    final production = ProductionCalculator.fromBuildings(
      widget.game.buildings,
      techBranches: widget.game.techBranches,
    );
    final consumption = computeConsumption(widget.game);
    final deactivated = computeBuildingsToDeactivate(
      widget.game, production);
    final unitsToLose = computeUnitsToLose(widget.game, deactivated);
    final confirmed = await showTurnConfirmationDialog(
      context,
      currentTurn: widget.game.turn,
      production: production,
      consumption: consumption,
      buildingsToDeactivate: deactivated,
      unitsToLose: unitsToLose,
      pendingExplorationCount: widget.game.pendingExplorations.length,
    );
    if (!confirmed || !mounted) return;
    final result = TurnResolver().resolve(widget.game);
    await widget.repository.save(widget.game);
    setState(() {});
    if (mounted) await showTurnSummaryDialog(context, result: result);
  }

  Future<void> _showSettings() async {
    if (!await showSettingsDialog(context) || !mounted) return;
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

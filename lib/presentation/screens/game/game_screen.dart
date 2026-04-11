import 'package:flutter/material.dart';
import '../../../data/game_repository.dart';
import '../../../domain/action/action_executor.dart';
import '../../../domain/action/end_turn_action.dart';
import '../../../domain/action/end_turn_action_result.dart';
import '../../../domain/building/building_type.dart';
import '../../../domain/game/game.dart';
import '../../../domain/game/player.dart';
import '../../../domain/resource/production_calculator.dart';
import '../../widgets/unit/army_list_view.dart';
import '../../widgets/turn/turn_confirmation_dialog.dart';
import '../../widgets/turn/turn_summary_dialog.dart';
import '../../widgets/building/building_list_view.dart';
import '../../widgets/common/game_bottom_bar.dart';
import '../../widgets/resource/resource_bar.dart';
import '../../widgets/common/settings_dialog.dart';
import '../../widgets/history/history_sheet.dart';
import '../../widgets/tech/tech_tree_view.dart';
import 'game_screen_actions.dart';
import 'game_screen_map_actions.dart';
import 'game_screen_tech_actions.dart';
import 'game_screen_turn_helpers.dart';
import '../menu/main_menu_screen.dart';

class GameScreen extends StatefulWidget {
  final Game game;
  final GameRepository repository;
  const GameScreen({
    super.key, required this.game, required this.repository});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int _currentTab = 0;
  int _currentLevel = 1;
  Player get _human => widget.game.humanPlayer;
  Set<int> get _unlockedLevels => widget.game.levels.keys.toSet();

  void _selectLevel(int level) {
    if (widget.game.levels.containsKey(level)) {
      setState(() => _currentLevel = level);
    }
  }

  @override
  Widget build(BuildContext context) {
    final production = ProductionCalculator.fromBuildings(
      _human.buildings, techBranches: _human.techBranches);
    final consumption = computeConsumption(_human);
    return Scaffold(
      body: Column(
        children: [
          ResourceBar(
            resources: _human.resources,
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
    final human = _human;
    return switch (_currentTab) {
      0 => BuildingListView(
        buildings: human.buildings,
        resources: human.resources,
        onBuildingTap: (b) => showBuildingDetailAction(
          context, g, b, () => setState(() {})),
      ),
      1 => buildMapTab(
        context,
        g,
        widget.repository,
        currentLevel: _currentLevel,
        unlockedLevels: _unlockedLevels,
        onLevelSelected: _selectLevel,
        onChanged: () => setState(() {}),
      ),
      2 => ArmyListView(
        unitsPerLevel: human.unitsPerLevel,
        barracksLevel: human.buildings[BuildingType.barracks]!.level,
        buildings: human.buildings,
        onUnitTap: (t) => showUnitDetailAction(
          context, g, t, () => setState(() {}),
          level: _currentLevel),
      ),
      3 => TechTreeView(
        techBranches: human.techBranches,
        buildings: human.buildings,
        resources: human.resources,
        onBranchTap: (branch) => showBranchDetail(
          context, g, branch, () => setState(() {})),
        onNodeTap: (branch, level) => showNodeDetail(
          context, g, branch, level, () => setState(() {})),
      ),
      _ => const SizedBox.shrink(),
    };
  }

  Future<void> _nextTurn() async {
    final human = _human;
    final production = ProductionCalculator.fromBuildings(
      human.buildings, techBranches: human.techBranches);
    final consumption = computeConsumption(human);
    final deactivated = computeBuildingsToDeactivate(human, production);
    final confirmed = await showTurnConfirmationDialog(context,
      currentTurn: widget.game.turn,
      production: production, consumption: consumption,
      buildingsToDeactivate: deactivated,
      unitsToLose: computeUnitsToLose(human, deactivated),
      pendingExplorationCount: human.pendingExplorations.length);
    if (!confirmed || !mounted) return;
    final result = (ActionExecutor().execute(
      EndTurnAction(), widget.game, _human) as EndTurnActionResult)
        .turnResult!;
    await widget.repository.save(widget.game);
    setState(() {});
    if (mounted) await showTurnSummaryDialog(context, result: result);
  }

  Future<void> _showSettings() async {
    final result = await showSettingsDialog(context);
    if (!mounted) return;
    switch (result) {
      case SettingsDialogResult.cancel: return;
      case SettingsDialogResult.openHistory:
        await showHistorySheet(context, player: _human);
      case SettingsDialogResult.saveAndQuit:
        await widget.repository.save(widget.game);
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(
            builder: (_) => MainMenuScreen(repository: widget.repository)),
          (_) => false);
    }
  }
}

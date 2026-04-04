import 'package:flutter/material.dart';
import '../../data/game_repository.dart';
import '../../domain/building.dart';
import '../../domain/building_type.dart';
import '../../domain/action_executor.dart';
import '../../domain/recruit_unit_action.dart';
import '../../domain/unit_cost_calculator.dart';
import '../../domain/unit_type.dart';
import '../../domain/upgrade_building_action.dart';
import '../../domain/game.dart';
import '../../domain/production_calculator.dart';
import '../../domain/turn_resolver.dart';
import '../widgets/army_list_view.dart';
import '../widgets/building_detail_sheet.dart';
import '../widgets/turn_confirmation_dialog.dart';
import '../widgets/turn_summary_dialog.dart';
import '../widgets/building_list_view.dart';
import '../widgets/game_bottom_bar.dart';
import '../widgets/resource_bar.dart';
import '../widgets/settings_dialog.dart';
import '../widgets/tab_placeholder.dart';
import '../widgets/tech_tree_view.dart';
import '../widgets/unit_detail_sheet.dart';
import 'game_screen_tech_actions.dart';
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
    final production = ProductionCalculator.fromBuildings(
      widget.game.buildings,
      techBranches: widget.game.techBranches,
    );
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
      2 => ArmyListView(
        units: widget.game.units,
        barracksLevel: widget.game.buildings[BuildingType.barracks]!.level,
        onUnitTap: _showUnitDetail,
      ),
      3 => TechTreeView(
        techBranches: widget.game.techBranches,
        buildings: widget.game.buildings,
        resources: widget.game.resources,
        onBranchTap: (branch) => showBranchDetail(
          context, widget.game, branch, () => setState(() {})),
        onNodeTap: (branch, level) => showNodeDetail(
          context, widget.game, branch, level, () => setState(() {})),
      ),
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

  void _showUnitDetail(UnitType unitType) {
    final calculator = UnitCostCalculator();
    final barracksLevel = widget.game.buildings[BuildingType.barracks]!.level;
    final isUnlocked = calculator.isUnlocked(unitType, barracksLevel);
    final count = widget.game.units[unitType]?.count ?? 0;
    final hasRecruitedThisType =
        widget.game.recruitedUnitTypes.contains(unitType);
    showUnitDetailSheet(
      context,
      unitType: unitType,
      count: count,
      isUnlocked: isUnlocked,
      barracksLevel: barracksLevel,
      resources: widget.game.resources,
      hasRecruitedThisType: hasRecruitedThisType,
      onRecruit: (quantity) => _recruitUnit(unitType, quantity),
    );
  }

  void _recruitUnit(UnitType unitType, int quantity) {
    final action = RecruitUnitAction(unitType: unitType, quantity: quantity);
    final result = ActionExecutor().execute(action, widget.game);
    if (result.isSuccess) {
      setState(() {});
      Navigator.pop(context);
    }
  }

  Future<void> _nextTurn() async {
    final production = ProductionCalculator.fromBuildings(
      widget.game.buildings,
      techBranches: widget.game.techBranches,
    );
    final confirmed = await showTurnConfirmationDialog(
      context, production: production);
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

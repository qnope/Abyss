import 'package:flutter/material.dart';
import '../../../data/game_repository.dart';
import '../../../domain/action/action_executor.dart';
import '../../../domain/action/end_turn_action.dart';
import '../../../domain/action/end_turn_action_result.dart';
import '../../../domain/building/building_type.dart';
import '../../../domain/game/game.dart';
import '../../../domain/game/player.dart';
import '../../../domain/objective/guide/guide_advisor.dart';
import '../../../domain/replay/seeded_random.dart';
import '../../widgets/unit/army_list_view.dart';
import '../../widgets/turn/turn_confirmation_dialog.dart';
import '../../widgets/building/building_list_view.dart';
import '../../widgets/common/game_bottom_bar.dart';
import '../../widgets/common/game_status_bars.dart';
import '../../widgets/resource/resource_bar.dart';
import '../../widgets/common/replay_export_dialog.dart';
import '../../widgets/common/settings_dialog.dart';
import '../../widgets/guide/guide_bubble.dart';
import '../../widgets/guide/guide_scope.dart';
import '../../widgets/history/history_sheet.dart';
import '../../widgets/tech/tech_tree_view.dart';
import '../../widgets/tip/tip_presenter.dart';
import 'game_screen_actions.dart';
import 'game_screen_event_actions.dart';
import 'game_screen_map_actions.dart';
import 'game_screen_tech_actions.dart';
import 'game_screen_turn_flow.dart';
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
  late final TipPresenter _tips =
      TipPresenter(game: widget.game, repository: widget.repository);
  Player get _human => widget.game.humanPlayer;
  Set<int> get _unlockedLevels => widget.game.levels.keys.toSet();

  void _selectLevel(int level) {
    if (widget.game.levels.containsKey(level)) {
      setState(() => _currentLevel = level);
    }
  }

  /// Redraws after a player's action, then opens the tip it may call for.
  void _changed() {
    setState(() {});
    _tips.showAfterAction(context);
  }

  @override
  Widget build(BuildContext context) {
    final production = computeProduction(widget.game, _human);
    final consumption = computeConsumption(widget.game, _human);
    final guide = GuideAdvisor.of(widget.game, _human);
    return GuideScope(target: guide?.target, child: Scaffold(
      body: Column(
        children: [
          ResourceBar(
            resources: _human.resources,
            production: production,
            consumption: consumption,
          ),
          GameStatusBars(game: widget.game, player: _human,
              onOpenEvent: _openPendingEvent),
          Expanded(child: _buildTabContent()),
          GuideBubble(advice: guide),
        ],
      ),
      bottomNavigationBar: GameBottomBar(
        currentTab: _currentTab,
        turnNumber: widget.game.turn,
        onTabChanged: (index) => setState(() => _currentTab = index),
        onNextTurn: _nextTurn,
        onSettings: _showSettings,
      ),
    ));
  }

  Widget _buildTabContent() {
    final g = widget.game;
    final human = _human;
    return switch (_currentTab) {
      0 => BuildingListView(
        buildings: human.buildings,
        resources: human.resources,
        worksite: human.worksite,
        onBuildingTap: (b) => showBuildingDetailAction(
          context, g, widget.repository, b, _changed),
      ),
      1 => buildMapTab(
        context,
        g,
        widget.repository,
        currentLevel: _currentLevel,
        unlockedLevels: _unlockedLevels,
        onLevelSelected: _selectLevel,
        onChanged: _changed,
      ),
      2 => ArmyListView(
        unitsPerLevel: human.unitsPerLevel,
        barracksLevel: human.buildings[BuildingType.barracks]!.level,
        buildings: human.buildings,
        onUnitTap: (t) => showUnitDetailAction(
          context, g, t, _changed,
          level: _currentLevel),
      ),
      3 => TechTreeView(
        techBranches: human.techBranches,
        buildings: human.buildings,
        resources: human.resources,
        researchDone: !human.worksite.canResearch,
        onUnlock: (branch) =>
          unlockBranch(g, branch, _changed),
        onResearch: (branch, option) =>
          researchTech(g, branch, option, _changed),
      ),
      _ => const SizedBox.shrink(),
    };
  }

  Future<void> _nextTurn() async {
    final human = _human;
    final production = computeProduction(widget.game, human);
    final consumption = computeConsumption(widget.game, human);
    final deactivated =
        computeBuildingsToDeactivate(widget.game, human, production);
    final confirmed = await showTurnConfirmationDialog(context,
      currentTurn: widget.game.turn,
      production: production, consumption: consumption,
      buildingsToDeactivate: deactivated,
      unitsToLose: computeUnitsToLose(widget.game, human, deactivated),
      pendingExplorationCount: human.pendingExplorations.length,
      raidWarning: dueWarnings(widget.game, human));
    if (!confirmed || !mounted) return;
    final result = (ActionExecutor().execute(
      EndTurnAction(random: SeededRandom.fresh()), widget.game, _human) as EndTurnActionResult)
        .turnResult!;
    await widget.repository.save(widget.game);
    setState(() {});
    if (!mounted) return;
    await showTurnOutcome(context, widget.game, widget.repository, result,
        _changed, tips: _tips);
  }

  void _openPendingEvent() {
    final pending = _human.eventState.pending;
    if (pending == null) return;
    openEventCard(context, widget.game, widget.repository, pending,
        _changed);
  }

  Future<void> _showSettings() async {
    final result = await showSettingsDialog(context,
        game: widget.game, repository: widget.repository);
    if (!mounted) return;
    setState(() {}); // The guide may have been switched on or off.
    switch (result) {
      case SettingsDialogResult.cancel: return;
      case SettingsDialogResult.openHistory:
        await showHistorySheet(context, player: _human);
      case SettingsDialogResult.exportReplay:
        await showReplayExportDialog(context, widget.game);
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

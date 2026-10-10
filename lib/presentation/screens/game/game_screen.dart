import 'package:flutter/material.dart';
import '../../../data/game_repository.dart';
import '../../../domain/game/game.dart';
import '../../../domain/game/player.dart';
import '../../../domain/objective/guide/guide_advisor.dart';
import '../../widgets/common/game_bottom_bar.dart';
import '../../widgets/common/game_status_bars.dart';
import '../../widgets/resource/resource_bar.dart';
import '../../widgets/guide/guide_bubble.dart';
import '../../widgets/guide/guide_scope.dart';
import '../../widgets/tip/tip_presenter.dart';
import 'game_screen_end_turn.dart';
import 'game_screen_event_actions.dart';
import 'game_screen_settings_actions.dart';
import 'game_screen_tabs.dart';
import 'game_screen_turn_flow.dart';
import 'game_screen_turn_helpers.dart';

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
          Expanded(
            child: buildGameTab(
              context,
              widget.game,
              widget.repository,
              tab: _currentTab,
              currentLevel: _currentLevel,
              onLevelSelected: _selectLevel,
              onChanged: _changed,
            ),
          ),
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

  Future<void> _nextTurn() async {
    final result =
        await confirmAndEndTurn(context, widget.game, widget.repository);
    if (result == null || !mounted) return;
    setState(() {});
    await showTurnOutcome(context, widget.game, widget.repository, result,
        _changed, tips: _tips);
  }

  void _openPendingEvent() {
    final pending = _human.eventState.pending;
    if (pending == null) return;
    openEventCard(context, widget.game, widget.repository, pending,
        _changed);
  }

  Future<void> _showSettings() => openGameSettings(
        context,
        widget.game,
        widget.repository,
        onClosed: () => setState(() {}),
      );
}

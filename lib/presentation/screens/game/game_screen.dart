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
import '../../widgets/map/effects/map_effects.dart';
import '../../widgets/tip/tip_presenter.dart';
import '../../widgets/turn/story_skip_button.dart';
import 'game_screen_end_turn.dart';
import 'game_screen_event_actions.dart';
import 'game_screen_settings_actions.dart';
import 'game_screen_story.dart';
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
  final MapEffects _effects = MapEffects();

  /// The story of the turn being told on the map, if any.
  Future<void>? _story;
  Player get _human => widget.game.humanPlayer;

  void _selectLevel(int level) {
    if (widget.game.levels.containsKey(level)) {
      setState(() => _currentLevel = level);
    }
  }

  /// Shows the map of [level].
  void _openMap(int level) => setState(() {
        _currentTab = mapTab;
        if (widget.game.levels.containsKey(level)) _currentLevel = level;
      });

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
              onOpenEvent: _openPendingEvent, onOpenMap: _openMap),
          Expanded(
            child: Stack(fit: StackFit.expand, children: [
              buildGameTab(
                context,
                widget.game,
                widget.repository,
                tab: _currentTab,
                currentLevel: _currentLevel,
                onLevelSelected: _selectLevel,
                onChanged: _changed,
                effects: _effects,
              ),
              if (_story != null)
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: StorySkipButton(onPressed: _effects.skip),
                ),
            ]),
          ),
          GuideBubble(advice: guide, turn: widget.game.turn),
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

  /// Ends the turn, tells its story on the map, then shows its outcome.
  /// The map stays open once the story is told, under the summary.
  Future<void> _nextTurn() async {
    final result = await confirmAndEndTurn(
        context, widget.game, widget.repository,
        observe: watchTurnStory(context, widget.game, _effects,
            showLevel: _openMap, onTold: (story) => _story = story));
    if (result == null || !mounted) return;
    setState(() {});
    await _story;
    if (!mounted) return;
    setState(() => _story = null);
    await showTurnOutcome(context, widget.game, widget.repository, result,
        _changed, tips: _tips);
  }

  @override
  void dispose() {
    _effects.dispose();
    super.dispose();
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

import 'dart:math';

import 'package:abyss/domain/event/effects/wreck_effect.dart';
import 'package:abyss/domain/event/event_rules.dart';
import 'package:abyss/domain/event/random_event_type.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/map/exploration_resolver.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_family.dart';
import 'package:abyss/domain/map/monster_lair.dart';
import 'package:abyss/domain/raid/noise_rules.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/script/strategies/event_moves.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../event/effects/wreck_test_helper.dart';
import 'event_moves_test_helper.dart';

/// Wreck sunk at the end of turn 12, searchable through turn 17, in a
/// game during [turn].
({Game game, Player player, GridPosition at}) _wreck({
  int turn = 13,
  int scouts = 1,
}) {
  final player = wreckPlayer(scouts: scouts);
  final game = wreckGame(player, turn: turn);
  const WreckEffect().onDraw(game, player, turn: 12, random: Random(4));
  return (game: game, player: player, at: player.eventState.wreckPosition!);
}

void main() {
  test('a scout explores the wreck, searched on the next turn', () {
    final w = _wreck();
    scriptTurnOf(w.game).fetchWreck();
    expect(w.player.pendingExplorations.single.target, w.at);

    ExplorationResolver.resolve(w.game);
    w.game.turn++;
    final int coral = w.player.resources[ResourceType.coral]!.amount;
    scriptTurnOf(w.game).fetchWreck();

    expect(w.game.levels[1]!.cellAt(w.at.x, w.at.y).isCollected, isTrue);
    expect(w.player.eventState.wreckPosition, isNull);
    expect(w.player.resources[ResourceType.coral]!.amount, greaterThan(coral));
    expect(w.player.raidState.noise, greaterThanOrEqualTo(20));
  });

  test('a wreck in sight is searched at once', () {
    final w = _wreck(scouts: 0);
    w.player.addRevealedCell(1, w.at);
    scriptTurnOf(w.game).fetchWreck();
    expect(w.player.eventState.wreckPosition, isNull);
  });

  test('left alone while its noise would draw a raid', () {
    const int room = NoiseRules.threshold - EventRules.wreckNoise;
    final loud = _wreck();
    loud.player.raidState.noise = room;
    loud.player.addRevealedCell(1, loud.at);
    scriptTurnOf(loud.game).fetchWreck();
    expect(loud.player.eventState.wreckPosition, loud.at);

    final hidden = _wreck();
    hidden.player.raidState.noise = room;
    scriptTurnOf(hidden.game).fetchWreck();
    expect(hidden.player.pendingExplorations, isEmpty);
  });

  test('left alone while a raid is announced', () {
    final w = _wreck();
    w.player.raidState.announce(
      const MonsterLair(
        difficulty: MonsterDifficulty.easy,
        family: MonsterFamily.swarm,
        unitCount: 3,
      ),
      14,
    );
    scriptTurnOf(w.game).fetchWreck();
    expect(w.player.pendingExplorations, isEmpty);
  });

  test('not explored in a storm, nor on its last turn', () {
    final storm = _wreck();
    storm.player.eventState.activate(RandomEventType.storm, untilTurn: 14);
    scriptTurnOf(storm.game).fetchWreck();
    expect(storm.player.pendingExplorations, isEmpty);

    final last = _wreck(turn: 12 + EventRules.wreckTurns);
    scriptTurnOf(last.game).fetchWreck();
    expect(last.player.pendingExplorations, isEmpty);
  });
}

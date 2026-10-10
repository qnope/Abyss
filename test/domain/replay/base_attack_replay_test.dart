import 'dart:math';

import 'package:abyss/domain/action/action_executor.dart';
import 'package:abyss/domain/action/end_turn_action.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/domain/replay/replay_export.dart';
import 'package:abyss/domain/replay/seeded_random.dart';
import 'package:abyss/domain/script/strategies/assault_moves.dart';
import 'package:abyss/domain/script/strategies/balanced_strategy.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/two_player_game.dart';
import 'two_player_replay_helper.dart';

/// Two players play [turns] turns; the rival sends all its fighters
/// against the human's base from turn [attackFrom] on, once.
Game _playWithAttack(int turns, {required int attackFrom}) {
  final two = TwoPlayerGame.create(rivalId: rivalId);
  final seeds = Random(5);
  final executor = ActionExecutor();
  var attacked = false;
  for (var t = 1; t <= turns; t++) {
    const BalancedStrategy().playTurn(LiveTurn(two.game, two.human, seeds));
    final turn = LiveTurn(two.game, two.rival, seeds);
    const BalancedStrategy().playTurn(turn);
    if (!attacked && t >= attackFrom) {
      final army = <UnitType, int>{
        for (final e in two.rival.unitsOnLevel(1).entries)
          if (e.value.count > 0) e.key: e.value.count,
      };
      attacked = army.isNotEmpty && turn.attackBase(two.human.id, army);
    }
    executor.execute(
      EndTurnAction(random: SeededRandom(seeds.nextInt(1 << 30))),
      two.game,
      two.human,
    );
  }
  return two.game;
}

void main() {
  test('a game with an attack replays to the same state, dice included', () {
    final live = _playWithAttack(16, attackFrom: 10);
    final rival = live.players[rivalId]!;

    expect(
      live.humanPlayer.historyEntries.whereType<BaseAssaultEntry>(),
      hasLength(1),
    );
    final json = ReplayExport.toJson(live);
    expect(
      (json['turns'] as Map).values
          .expand((a) => a as List)
          .any((a) => (a as Map)['do'] == 'attackPlayer' && a['seed'] is int),
      isTrue,
    );

    final replayed = replayOn(json);

    expect(both(replayed), both(live));
    final damage =
        replayed.humanPlayer.buildings[BuildingType.headquarters]!.level;
    expect(
      damage,
      live.humanPlayer.buildings[BuildingType.headquarters]!.level,
    );
    expect(
      replayed.players[rivalId]!.historyEntries.whereType<BaseAssaultEntry>(),
      hasLength(rival.historyEntries.whereType<BaseAssaultEntry>().length),
    );
  });
}

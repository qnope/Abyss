import 'dart:math';

import 'package:abyss/domain/action/action_executor.dart';
import 'package:abyss/domain/action/end_turn_action.dart';
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

/// Two players play [turns] turns; from [announceFrom] on the rival
/// announces, once, an attack with all its fighters on the human.
Game _playWithAnnouncement(int turns, {required int announceFrom}) {
  final two = TwoPlayerGame.create(rivalId: rivalId);
  final seeds = Random(5);
  final executor = ActionExecutor();
  var announced = false;
  for (var t = 1; t <= turns; t++) {
    const BalancedStrategy().playTurn(LiveTurn(two.game, two.human, seeds));
    final turn = LiveTurn(two.game, two.rival, seeds);
    const BalancedStrategy().playTurn(turn);
    if (!announced && t >= announceFrom) {
      final army = <UnitType, int>{
        for (final e in two.rival.unitsOnLevel(1).entries)
          if (e.value.count > 0 && e.key != UnitType.scout)
            e.key: e.value.count,
      };
      announced = army.isNotEmpty && turn.announceAttack(army);
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
  test('an announced attack replays to the same game without any brain', () {
    final live = _playWithAnnouncement(18, announceFrom: 10);

    expect(
      live.humanPlayer.historyEntries.whereType<BaseAssaultEntry>(),
      hasLength(1),
      reason: 'announced at 10 or later, fought two turns on',
    );
    final json = ReplayExport.toJson(live);
    final journalled = (json['turns'] as Map).values
        .expand((a) => a as List)
        .where((a) => (a as Map)['do'] == 'announceAttack');
    expect(journalled, hasLength(1));
    expect((journalled.single as Map)['seed'], isA<int>());
    expect((journalled.single as Map)['player'], rivalId);
    expect(json['exact'], isTrue);

    final replayed = replayOn(json);

    expect(both(replayed), both(live));
    expect(
      replayed.humanPlayer.historyEntries.whereType<BaseAssaultEntry>(),
      hasLength(1),
    );
  });

  test('a replay stopped between the announcement and the fight agrees', () {
    final live = [
      for (var turns = 11; turns < 18; turns++)
        _playWithAnnouncement(turns, announceFrom: 10),
    ].firstWhere((g) => g.humanPlayer.raidState.attacks.isNotEmpty);

    final replayed = replayOn(ReplayExport.toJson(live));

    expect(replayed.humanPlayer.raidState.attacks, hasLength(1));
    expect(both(replayed), both(live));
  });
}

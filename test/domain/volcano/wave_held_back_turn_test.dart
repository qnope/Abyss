import 'package:abyss/domain/action/action_executor.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/map/monster_lair.dart';
import 'package:abyss/domain/replay/seeded_random.dart';
import 'package:abyss/domain/turn/turn_resolver.dart';
import 'package:abyss/domain/turn/turn_result.dart';
import 'package:abyss/domain/volcano/volcano_wave_factory.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/kernel_war_helper.dart';

final MonsterLair _wave = VolcanoWaveFactory.fromKernelLevel(4);

/// A kraken wave is due on [war]'s kernel at the
/// end of the turn, a faction wins a siege of it during that turn (as the
/// factions play before the end-of-turn resolver), then the turn ends.
TurnResult _siegeThenEndTurn(KernelWar war) {
  war.owner.volcanoState.announce(_wave, war.game.turn);
  final result = ActionExecutor().execute(
    war.strike(horde),
    war.game,
    war.attacker,
  );
  expect(result.isSuccess, isTrue, reason: '${result.reason}');
  return TurnResolver().resolve(war.game, random: SeededRandom(3));
}

void main() {
  KernelWar war({required bool humanHolds}) =>
      KernelWar(kernelLevel: 4, humanHolds: humanHolds)
        ..arm()
        ..garrison(smallGarrison);

  test('a won siege on a faction kernel costs it one level only', () {
    final w = war(humanHolds: false);
    final turn = w.game.turn;

    _siegeThenEndTurn(w);

    expect(w.kernelOf(w.owner), 3);
    expect(w.owner.volcanoState.arrivalTurn, turn + 1);
  });

  test('a won siege on the human kernel costs one level, the wave is told', () {
    final w = war(humanHolds: true);
    final turn = w.game.turn;

    final result = _siegeThenEndTurn(w);

    final Player human = w.human;
    expect(w.kernelOf(human), 3);
    expect(result.volcano, isNull);
    expect(result.announcedWave, same(_wave));
    expect(human.volcanoState.arrivalTurn, turn + 1);
  });
}

import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/map/transition_base_type.dart';
import 'package:abyss/domain/replay/seeded_random.dart';
import 'package:abyss/domain/script/script_turn.dart';
import 'package:abyss/domain/script/strategies/contest_moves.dart';
import 'package:abyss/domain/volcano/kernel_garrison.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/kernel_war_helper.dart' as kernel;
import '../../../helpers/post_attack_helper.dart';

ScriptTurn _turnOf(dynamic war) => ScriptTurn(
  game: war.game as Game,
  player: war.human as Player,
  random: SeededRandom(1),
  log: [],
);

void main() {
  test('a player takes the weakly held post of a faction it has seen', () {
    final war = PostWar(TransitionBaseType.faille);
    war.arm(war.human);
    war.put(war.owner, war.below, garrison);

    expect(_turnOf(war).contest(), isTrue);
    expect(war.post.capturedBy, war.human.id);
  });

  test('it leaves a post it would not beat', () {
    final war = PostWar(TransitionBaseType.faille);
    war.arm(war.human, {});
    war.put(war.human, war.level, {});
    war.put(war.owner, war.below, wall);

    expect(_turnOf(war).contest(), isFalse);
    expect(war.post.capturedBy, war.owner.id);
  });

  test('a player besieges a weakly garrisoned kernel', () {
    final war = kernel.KernelWar(kernelLevel: 1);
    war.put(war.human, KernelGarrison.volcanoLevel, kernel.horde);
    war.garrison(kernel.smallGarrison);

    expect(_turnOf(war).contest(), isTrue);
    expect(war.holder, war.human.id);
  });

  test('with nothing held by others there is nothing to contest', () {
    final war = kernel.KernelWar(kernelLevel: 1);
    war.put(war.human, KernelGarrison.volcanoLevel, kernel.horde);
    war.garrison(kernel.smallGarrison);
    war.game.players.removeWhere((id, p) => id != war.human.id);

    expect(_turnOf(war).contest(), isFalse);
  });
}

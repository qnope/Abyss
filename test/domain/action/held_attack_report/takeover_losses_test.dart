import 'package:abyss/domain/action/kernel_takeover.dart';
import 'package:abyss/domain/action/post_takeover.dart';
import 'package:abyss/domain/map/transition_base_type.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/domain/volcano/kernel_garrison.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/kernel_war_helper.dart';
import '../../../helpers/post_attack_helper.dart';

void main() {
  test('a post taken returns the units its owner had below', () {
    final war = PostWar(TransitionBaseType.faille);
    war.put(war.owner, war.below, const {UnitType.scout: 2});
    war.put(war.owner, 1, const {UnitType.guardian: 4});

    final lost = PostTakeover.apply(
      post: war.post,
      attacker: war.attacker,
      owner: war.owner,
    );

    expect(lost, {UnitType.scout: 2});
  });

  Map<UnitType, int> take(KernelWar war, int after) => KernelTakeover.apply(
    map: war.game.levels[KernelGarrison.volcanoLevel]!,
    x: war.at.x,
    y: war.at.y,
    attacker: war.attacker,
    owner: war.owner,
    after: after,
  );

  test('a kernel taken returns its garrison', () {
    final war = KernelWar(kernelLevel: 1)..garrison(smallGarrison);

    expect(take(war, 0), smallGarrison);
    expect(war.holder, war.attacker.id);
  });

  test('a kernel that only loses a level keeps its garrison', () {
    final war = KernelWar(kernelLevel: 3)..garrison(smallGarrison);

    expect(take(war, 2), isEmpty);
    expect(war.kernelOf(war.owner), 2);
    expect(war.holder, war.owner.id);
  });
}

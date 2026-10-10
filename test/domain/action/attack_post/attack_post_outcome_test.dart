import 'package:abyss/domain/action/action_executor.dart';
import 'package:abyss/domain/action/attack_base_result.dart';
import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/domain/map/transition_base_type.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/domain/volcano/kernel_garrison.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/post_attack_helper.dart';

AttackBaseResult _run(PostWar war, Map<UnitType, int> army) =>
    ActionExecutor().execute(war.strike(army), war.game, war.attacker)
        as AttackBaseResult;

void main() {
  group('who defends', () {
    test('the Faille is defended by the level 2 units of its owner', () {
      final war = PostWar(TransitionBaseType.faille);
      war.arm(war.attacker, {UnitType.harpoonist: 12});
      war.put(war.owner, 2, wall);
      war.put(war.owner, 1, {UnitType.harpoonist: 5});

      final result = _run(war, {UnitType.harpoonist: 12});

      expect(result.defence.engaged, wall);
      expect(result.victory, isFalse);
      expect(war.count(war.owner, 1, UnitType.harpoonist), 5);
    });

    test('the Cheminée is defended by the level 3 units, garrison apart', () {
      final war = PostWar(TransitionBaseType.cheminee);
      war.arm(war.attacker, {UnitType.harpoonist: 12});
      war.put(war.owner, 3, {UnitType.guardian: 40});
      war.put(war.owner, 2, {UnitType.harpoonist: 9});
      war.put(war.owner, KernelGarrison.stockKey, {UnitType.harpoonist: 70});

      final result = _run(war, {UnitType.harpoonist: 12});

      expect(result.defence.engaged, {UnitType.guardian: 40});
      expect(war.count(war.owner, 4, UnitType.harpoonist), 70);
    });

    test('a post without defender falls at once', () {
      final war = PostWar(TransitionBaseType.faille);
      war.arm(war.attacker, {UnitType.scout: 1});

      final result = _run(war, {UnitType.scout: 1});

      expect(result.victory, isTrue);
      expect(result.defence.engaged, isEmpty);
    });
  });

  group('a lost attack', () {
    test('keeps the post, the passage and the defenders that survive', () {
      final war = PostWar(TransitionBaseType.cheminee);
      war.arm(war.attacker, {UnitType.harpoonist: 6});
      war.put(war.owner, 3, wall);

      final result = _run(war, {UnitType.harpoonist: 6});

      expect(result.victory, isFalse);
      expect(war.post.capturedBy, war.owner.id);
      expect(war.owner.buildings[war.passage]!.level, 2);
      expect(war.count(war.owner, 3, UnitType.guardian), greaterThan(0));
      expect(war.count(war.attacker, 2, UnitType.harpoonist), lessThan(6));
      expect(
        war.owner.historyEntries.whereType<BaseAssaultEntry>().single.victory,
        isFalse,
      );
    });
  });
}

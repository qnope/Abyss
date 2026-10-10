import 'package:abyss/domain/action/action_executor.dart';
import 'package:abyss/domain/action/attack_base_result.dart';
import 'package:abyss/domain/action/descend_action.dart';
import 'package:abyss/domain/action/action_failure.dart';
import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/domain/map/transition_base_type.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/domain/volcano/kernel_garrison.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/post_attack_helper.dart';

AttackBaseResult _run(PostWar war, Map<UnitType, int> army) =>
    ActionExecutor().execute(war.strike(army), war.game, war.attacker)
        as AttackBaseResult;

void main() {
  group('a won attack', () {
    for (final kind in TransitionBaseType.values) {
      test('destroys the passage and gives the post: ${kind.name}', () {
        final war = PostWar(kind);
        war.arm(war.attacker);
        war.put(war.owner, war.below, garrison);
        final former = war.owner.id;

        final result = _run(war, horde);

        expect(result.victory, isTrue);
        expect(war.owner.buildings[war.passage]!.level, 0);
        expect(war.post.capturedBy, war.attacker.id);
        expect(war.post.capturedBy, isNot(former));
      });
    }

    test('loses the units the former owner had on that level', () {
      final war = PostWar(TransitionBaseType.faille);
      war.arm(war.attacker);
      war.put(war.owner, 2, garrison);
      war.put(war.owner, 1, {UnitType.guardian: 4});

      _run(war, horde);

      expect(war.count(war.owner, 2, UnitType.harpoonist), 0);
      expect(war.count(war.owner, 1, UnitType.guardian), 4);
    });

    test('leaves the post empty until the attacker builds its passage', () {
      final war = PostWar(TransitionBaseType.faille);
      war.arm(war.attacker);
      war.put(war.owner, 2, garrison);

      _run(war, horde);

      expect(war.attacker.buildings[war.passage]!.level, 0);
      for (final p in [war.attacker, war.owner]) {
        expect(
          KernelGarrison.stockAt(
            p,
            2,
          ).values.fold<int>(0, (a, u) => a + u.count),
          0,
        );
      }
    });

    test('refuses the descent to the former owner, then to the attacker '
        'until it has built its own', () {
      final war = PostWar(TransitionBaseType.faille);
      war.arm(war.attacker);
      war.put(war.owner, 1, {UnitType.guardian: 4});
      war.put(war.owner, 2, garrison);
      _run(war, horde);
      DescendAction descend(UnitType t) => DescendAction(
        transitionX: war.at.x,
        transitionY: war.at.y,
        fromLevel: 1,
        selectedUnits: {t: 1},
      );
      war.put(war.owner, 1, {UnitType.guardian: 4});
      war.arm(war.attacker, {UnitType.harpoonist: 2});

      expect(
        descend(UnitType.guardian).validate(war.game, war.owner).reason,
        ActionFailure.baseNotCaptured,
      );
      expect(
        descend(UnitType.harpoonist).validate(war.game, war.attacker).reason,
        ActionFailure.requiredBuildingMissing,
      );
      war.attacker.buildings[war.passage] = Building(
        type: war.passage,
        level: 1,
      );
      final result = ActionExecutor().execute(
        descend(UnitType.harpoonist),
        war.game,
        war.attacker,
      );
      expect(result.isSuccess, isTrue);
      expect(war.count(war.attacker, 2, UnitType.harpoonist), 1);
    });

    test('pillages nothing and leaves the base alone', () {
      final war = PostWar(TransitionBaseType.faille);
      war.arm(war.attacker);
      war.put(war.owner, 2, garrison);
      final stock = {
        for (final e in war.owner.resources.entries) e.key: e.value.amount,
      };
      final mine = war.attacker.resources[ResourceType.algae]!.amount;
      final levels = {
        for (final e in war.owner.buildings.entries)
          if (e.key != war.passage) e.key: e.value.level,
      };

      final result = _run(war, horde);

      expect(result.damage.pillaged, isEmpty);
      expect(result.damage.loot, isEmpty);
      expect({
        for (final e in war.owner.resources.entries) e.key: e.value.amount,
      }, stock);
      expect(war.attacker.resources[ResourceType.algae]!.amount, mine);
      expect({
        for (final e in war.owner.buildings.entries)
          if (e.key != war.passage) e.key: e.value.level,
      }, levels);
    });

    test('costs the attacker its casualties as any fight', () {
      final war = PostWar(TransitionBaseType.faille);
      war.arm(war.attacker);
      war.put(war.owner, 2, {UnitType.guardian: 25, UnitType.harpoonist: 25});

      final result = _run(war, horde);

      final back = war.count(war.attacker, 1, UnitType.harpoonist);
      expect(
        back,
        result.survivorsIntact.values.fold(0, (a, b) => a + b) +
            result.wounded.values.fold(0, (a, b) => a + b),
      );
      expect(back, lessThan(60));
    });

    test('writes a history entry for each side', () {
      final war = PostWar(TransitionBaseType.faille);
      war.arm(war.attacker);
      war.put(war.owner, 2, garrison);

      _run(war, horde);

      final mine =
          war.attacker.historyEntries.whereType<BaseAssaultEntry>().single;
      final theirs =
          war.owner.historyEntries.whereType<BaseAssaultEntry>().single;
      expect(mine.defending, isFalse);
      expect(theirs.defending, isTrue);
      expect(mine.victory && theirs.victory, isTrue);
      expect(mine.opponentName, war.owner.name);
      expect(theirs.opponentName, war.attacker.name);
      expect(mine.postName, war.post.name);
      expect(theirs.postName, war.post.name);
      expect(mine.pillaged, isEmpty);
    });

    test('is felt as a fight by the noise gauge', () {
      final war = PostWar(TransitionBaseType.faille);
      war.arm(war.attacker);
      final before = war.attacker.raidState.noise;

      _run(war, horde);

      expect(war.attacker.raidState.noise, greaterThan(before));
    });
  });
}

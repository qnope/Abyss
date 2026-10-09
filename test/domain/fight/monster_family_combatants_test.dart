import 'package:abyss/domain/fight/combatant.dart';
import 'package:abyss/domain/fight/combatant_builder.dart';
import 'package:abyss/domain/fight/monster_unit_stats.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_family.dart';
import 'package:abyss/domain/map/monster_lair.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a family lair fights with its family stats and key', () {
    const lair = MonsterLair(
      difficulty: MonsterDifficulty.medium,
      unitCount: 3,
      family: MonsterFamily.armoured,
    );
    final List<Combatant> combatants = CombatantBuilder.monsterCombatantsFrom(
      lair,
    );
    final stats = MonsterUnitStats.of(MonsterFamily.armoured, 2);
    expect(combatants, hasLength(3));
    for (final Combatant c in combatants) {
      expect(c.typeKey, 'armouredL2');
      expect(c.def, stats.def);
      expect(c.isBoss, isFalse);
    }
  });

  test('a raid wave fields both of its families', () {
    const wave = MonsterLair(
      difficulty: MonsterDifficulty.easy,
      unitCount: 4,
      family: MonsterFamily.swarm,
      secondFamily: MonsterFamily.hunter,
      secondCount: 2,
    );
    final keys =
        CombatantBuilder.monsterCombatantsFrom(
          wave,
        ).map((Combatant c) => c.typeKey).toList();
    expect(keys.where((k) => k == 'swarmL1'), hasLength(4));
    expect(keys.where((k) => k == 'hunterL1'), hasLength(2));
    expect(wave.totalCount, 6);
  });

  test('colossi are bosses', () {
    const lair = MonsterLair(
      difficulty: MonsterDifficulty.hard,
      unitCount: 2,
      family: MonsterFamily.colossus,
    );
    expect(
      CombatantBuilder.monsterCombatantsFrom(lair).every((c) => c.isBoss),
      isTrue,
    );
  });

  test('a family is read back from its combatant key', () {
    for (final MonsterFamily family in MonsterFamily.values) {
      expect(
        MonsterFamily.ofTypeKey(MonsterFamily.typeKeyOf(family, 3)),
        family,
      );
    }
    expect(MonsterFamily.ofTypeKey('monsterL1'), isNull);
    expect(MonsterFamily.ofTypeKey('harpoonist'), isNull);
  });

  test('family sizes stand for the same generic lair', () {
    expect(MonsterUnitStats.countFor(MonsterFamily.swarm, 20), 60);
    expect(MonsterUnitStats.countFor(MonsterFamily.armoured, 20), 14);
    expect(MonsterUnitStats.countFor(MonsterFamily.hunter, 20), 16);
    expect(MonsterUnitStats.countFor(MonsterFamily.colossus, 20), 3);
    expect(MonsterUnitStats.countFor(MonsterFamily.colossus, 1), 1);
    expect(MonsterUnitStats.countFor(null, 20), 20);
  });
}

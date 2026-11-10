import 'package:abyss/domain/fight/combat_role.dart';
import 'package:abyss/domain/fight/monster_unit_stats.dart';
import 'package:abyss/domain/map/monster_family.dart';
import 'package:abyss/domain/unit/unit_stats.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/vectors/domain/fight_rule_vectors.dart';
import 'vector_reader.dart';

void main() {
  final vectors = VectorReader(FightRuleVectors.file);

  group('FightRuleVectors', () {
    test('compute a blow for every ATK and DEF that fights', () {
      final atks = vectors.valuesOf('damage', 'atk');
      final defs = (vectors.cases('damage').first['defs']! as List).toSet();
      for (final type in UnitType.values) {
        expect(atks, contains(UnitStats.forType(type).atk));
        expect(defs, contains(UnitStats.forType(type).def));
      }
      for (final family in <MonsterFamily?>[null, ...MonsterFamily.values]) {
        for (var level = 1; level <= 3; level++) {
          expect(atks, contains(MonsterUnitStats.of(family, level).atk));
          expect(defs, contains(MonsterUnitStats.of(family, level).def));
        }
      }
    });

    test('never deal less than 1, crits and multipliers stacking', () {
      for (final c in vectors.cases('damage')) {
        for (final List<Object?> blow in (c['out']! as List).cast()) {
          expect(blow, hasLength(5));
          expect(blow[0]! as int, greaterThanOrEqualTo(1));
          expect(blow[2]! as int, greaterThanOrEqualTo(blow[0]! as int));
          expect(blow[4]! as int, greaterThan(blow[1]! as int));
        }
      }
    });

    test('pit one combatant of each kind against the other side', () {
      final samples = FightRuleVectors.samples();
      expect({for (final c in samples) c.role}, CombatRole.values.toSet());
      expect(
        {for (final c in samples) c.family},
        {null, ...MonsterFamily.values},
      );
      final outs = vectors.outs('attackDamage').cast<Map<String, Object?>>();
      expect({for (final o in outs) o['multiplier']}.length, greaterThan(1));
      expect(outs.where((o) => o['hunts'] == true), isNotEmpty);
      expect(
        {for (final o in outs) o['role']},
        {for (final role in CombatRole.values) role.name},
      );
    });

    test('describe every monster family at its three levels', () {
      expect(vectors.valuesOf('monsters', 'family'), {
        null,
        for (final family in MonsterFamily.values) family.name,
      });
      for (final Map<Object?, Object?> o in vectors.outs('monsters').cast()) {
        expect(o['stats'], hasLength(3));
        expect(o['typeKeys'], hasLength(3));
      }
      expect(vectors.cases('monsterLevels'), hasLength(3));
    });

    test('field the guardians, the ramparts and the leviathan', () {
      expect(vectors.valuesOf('guardians', 'of'), hasLength(3));
      expect(vectors.outs('magmaRampart').first, isNull);
      expect(vectors.outs('magmaRampart').last, isNotNull);
      expect({for (final o in vectors.outs('leviathan')) '$o'}.length,
          greaterThan(4));
    });
  });
}

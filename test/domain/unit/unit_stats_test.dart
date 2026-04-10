import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/unit/unit_stats.dart';
import 'package:abyss/domain/unit/unit_type.dart';

void main() {
  group('UnitStats.forType', () {
    test('scout', () {
      final stats = UnitStats.forType(UnitType.scout);
      expect(stats.hp, 10);
      expect(stats.atk, 2);
      expect(stats.def, 1);
    });

    test('harpoonist', () {
      final stats = UnitStats.forType(UnitType.harpoonist);
      expect(stats.hp, 15);
      expect(stats.atk, 5);
      expect(stats.def, 2);
    });

    test('guardian', () {
      final stats = UnitStats.forType(UnitType.guardian);
      expect(stats.hp, 25);
      expect(stats.atk, 2);
      expect(stats.def, 6);
    });

    test('domeBreaker', () {
      final stats = UnitStats.forType(UnitType.domeBreaker);
      expect(stats.hp, 20);
      expect(stats.atk, 8);
      expect(stats.def, 3);
    });

    test('abyssAdmiral', () {
      final stats = UnitStats.forType(UnitType.abyssAdmiral);
      expect(stats.hp, 100);
      expect(stats.atk, 0);
      expect(stats.def, 0);
    });

    test('saboteur', () {
      final stats = UnitStats.forType(UnitType.saboteur);
      expect(stats.hp, 8);
      expect(stats.atk, 10);
      expect(stats.def, 1);
    });
  });
}

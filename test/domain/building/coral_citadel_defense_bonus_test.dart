import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/building/coral_citadel_defense_bonus.dart';

void main() {
  group('CoralCitadelDefenseBonus.multiplierForLevel', () {
    test('level 0 returns 1.0', () {
      expect(CoralCitadelDefenseBonus.multiplierForLevel(0), 1.0);
    });

    test('level 1 returns 1.2', () {
      expect(CoralCitadelDefenseBonus.multiplierForLevel(1), 1.2);
    });

    test('level 2 returns 1.4', () {
      expect(CoralCitadelDefenseBonus.multiplierForLevel(2), 1.4);
    });

    test('level 3 returns 1.6', () {
      expect(CoralCitadelDefenseBonus.multiplierForLevel(3), 1.6);
    });

    test('level 4 returns 1.8', () {
      expect(CoralCitadelDefenseBonus.multiplierForLevel(4), 1.8);
    });

    test('level 5 returns 2.0', () {
      expect(CoralCitadelDefenseBonus.multiplierForLevel(5), 2.0);
    });

    test('negative level clamps to 1.0', () {
      expect(CoralCitadelDefenseBonus.multiplierForLevel(-3), 1.0);
    });

    test('level above max clamps to 2.0', () {
      expect(CoralCitadelDefenseBonus.multiplierForLevel(7), 2.0);
    });
  });

  group('CoralCitadelDefenseBonus.multiplierFromBuildings', () {
    test('empty buildings map returns 1.0', () {
      expect(
        CoralCitadelDefenseBonus.multiplierFromBuildings({}),
        1.0,
      );
    });

    test('coralCitadel at level 0 returns 1.0', () {
      final buildings = {
        BuildingType.coralCitadel: Building(
          type: BuildingType.coralCitadel,
          level: 0,
        ),
      };
      expect(
        CoralCitadelDefenseBonus.multiplierFromBuildings(buildings),
        1.0,
      );
    });

    test('coralCitadel at level 3 returns 1.6', () {
      final buildings = {
        BuildingType.coralCitadel: Building(
          type: BuildingType.coralCitadel,
          level: 3,
        ),
      };
      expect(
        CoralCitadelDefenseBonus.multiplierFromBuildings(buildings),
        1.6,
      );
    });
  });

  group('CoralCitadelDefenseBonus.bonusLabel', () {
    test('level 0 returns "aucun"', () {
      expect(CoralCitadelDefenseBonus.bonusLabel(0), 'aucun');
    });

    test('level 1 returns "+20%"', () {
      expect(CoralCitadelDefenseBonus.bonusLabel(1), '+20%');
    });

    test('level 5 returns "+100%"', () {
      expect(CoralCitadelDefenseBonus.bonusLabel(5), '+100%');
    });
  });
}

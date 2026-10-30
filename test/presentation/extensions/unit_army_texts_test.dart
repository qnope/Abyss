import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/extensions/unit_army_texts.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/l10n_fixtures.dart';

void main() {
  const harpoonist = UnitType.harpoonist, guardian = UnitType.guardian;

  group('plaqueName', () {
    test('names one unit in the singular', () {
      expect(harpoonist.plaqueName(fr, 1), 'Harponneur');
      expect(UnitType.abyssAdmiral.plaqueName(fr, 1), 'Amiral des Abysses');
    });

    test('names an empty squad or several units in the plural', () {
      expect(harpoonist.plaqueName(fr, 22), 'Harponneurs');
      expect(UnitType.domeBreaker.plaqueName(fr, 0), 'Briseurs');
      expect(UnitType.abyssAdmiral.plaqueName(fr, 3), 'Amiraux des abysses');
    });

    test('names a locked squad in the singular', () {
      expect(guardian.plaqueName(fr, 0, locked: true), 'Gardien');
    });

    test('names the squads in English and Spanish', () {
      expect(harpoonist.plaqueName(en, 1500), 'Harpooners');
      expect(UnitType.scout.plaqueName(es, 4), 'Exploradores');
      expect(guardian.plaqueName(es, 1), 'Guardián');
    });
  });

  group('armyLabel', () {
    test('says how many units a squad holds and whether it recruits', () {
      expect(
        harpoonist.armyLabel(fr, count: 22, locked: false, recruitable: true),
        'Harponneurs, 22 unités, recrutable',
      );
      expect(
        UnitType.scout.armyLabel(
          fr,
          count: 1,
          locked: false,
          recruitable: false,
        ),
        'Éclaireur, 1 unité',
      );
    });

    test('says which barracks level a locked squad waits for', () {
      expect(
        guardian.armyLabel(fr, count: 0, locked: true, recruitable: true),
        'Gardien, verrouillé, Caserne niveau 3',
      );
      expect(
        UnitType.saboteur.armyLabel(
          en,
          count: 0,
          locked: true,
          recruitable: false,
        ),
        'Saboteur, locked, Barracks level 5',
      );
    });

    test('reads in Spanish', () {
      expect(
        harpoonist.armyLabel(es, count: 2, locked: false, recruitable: true),
        'Arponeros, 2 unidades, reclutable',
      );
    });
  });

  test('the lock pill names the barracks level', () {
    expect(fr.armyLockPill(3), 'Caserne niv. 3');
    expect(en.armyLockPill(5), 'Barracks lv. 5');
  });
}

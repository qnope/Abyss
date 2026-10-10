import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/extensions/unit_type_extensions.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/l10n_fixtures.dart';

void main() {
  test('names the units in French, with their accents', () {
    expect(UnitType.scout.displayName(fr), 'Éclaireur');
    expect(UnitType.domeBreaker.displayName(fr), 'Briseur');
    expect(UnitType.scout.role(fr), 'Éclaireur');
    expect(UnitType.domeBreaker.role(fr), 'Siège');
  });

  test('names the units in English and Spanish', () {
    expect(UnitType.harpoonist.displayName(en), 'Harpooner');
    expect(UnitType.abyssAdmiral.displayName(en), 'Abyss Admiral');
    expect(UnitType.scout.displayName(es), 'Explorador');
    expect(UnitType.saboteur.displayName(es), 'Saboteador');
  });

  test('every unit has a role and its effect in each language', () {
    for (final l10n in [fr, en, es]) {
      for (final type in UnitType.values) {
        expect(type.displayName(l10n), isNotEmpty);
        expect(type.role(l10n), isNotEmpty);
        expect(type.roleEffect(l10n), endsWith('.'));
      }
    }
  });

  test('describes the role effects', () {
    expect(UnitType.guardian.roleEffect(fr),
        'Provoque : les monstres le ciblent en priorité.');
    expect(UnitType.domeBreaker.roleEffect(en),
        'Deals double damage to bosses.');
    expect(UnitType.saboteur.role(es), 'Cañón de cristal');
  });
}

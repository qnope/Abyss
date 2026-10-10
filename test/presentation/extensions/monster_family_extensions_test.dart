import 'dart:io';

import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_family.dart';
import 'package:abyss/presentation/extensions/monster_family_extensions.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/l10n_fixtures.dart';

void main() {
  const MonsterFamily? generic = null;

  test('every family has a sprite for every level', () {
    for (final MonsterFamily family in MonsterFamily.values) {
      for (final MonsterDifficulty difficulty in MonsterDifficulty.values) {
        expect(File(family.svgPathAt(difficulty)).existsSync(), isTrue,
            reason: family.svgPathAt(difficulty));
      }
    }
  });

  test('older games keep the generic sprites and wording', () {
    expect(generic.svgPathAt(MonsterDifficulty.easy),
        'assets/icons/map_content/monster_easy.svg');
    expect(generic.label(fr), 'Rôdeurs');
    expect(generic.monsters(fr, 1), '1 monstre');
    expect(generic.weakness(fr), isNull);
    expect(generic.rule(fr), isNull);
  });

  test('every family names its monsters, its rule and its answer', () {
    expect(MonsterFamily.swarm.monsters(fr, 30), '30 Dents-de-verre');
    expect(MonsterFamily.hunter.monsters(fr, 1), '1 Calmar-chasseur');
    for (final l10n in [fr, en, es]) {
      for (final MonsterFamily family in MonsterFamily.values) {
        expect(family.label(l10n), isNotEmpty);
        expect(family.rule(l10n), isNotNull);
        expect(family.weakness(l10n), isNotNull);
      }
    }
  });

  test('counts the monsters in the plural of each language', () {
    expect(MonsterFamily.armoured.monsters(fr, 12), '12 Isopodes cuirassés');
    expect(MonsterFamily.armoured.monsters(fr, 1), '1 Isopode cuirassé');
    expect(generic.monsters(fr, 0), '0 monstre');
    expect(generic.monsters(en, 1), '1 monster');
    expect(generic.monsters(en, 3), '3 monsters');
    expect(MonsterFamily.hunter.monsters(en, 2), '2 Hunter Squids');
    expect(MonsterFamily.hunter.monsters(es, 1), '1 Calamar cazador');
    expect(MonsterFamily.hunter.monsters(es, 4), '4 Calamares cazadores');
  });

  test('names the families and their answers in English and Spanish', () {
    expect(MonsterFamily.armoured.label(en), 'Shells');
    expect(MonsterFamily.colossus.label(es), 'Colosos');
    expect(generic.label(es), 'Merodeadores');
    expect(MonsterFamily.swarm.weakness(en), 'Harpooners');
    expect(MonsterFamily.kraken.weakness(es), 'Rompedores de cúpulas');
  });
}

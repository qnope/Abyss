import 'dart:io';

import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_family.dart';
import 'package:abyss/presentation/extensions/monster_family_extensions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every family has a sprite for every level', () {
    for (final MonsterFamily family in MonsterFamily.values) {
      for (final MonsterDifficulty difficulty in MonsterDifficulty.values) {
        expect(File(family.svgPathAt(difficulty)).existsSync(), isTrue,
            reason: family.svgPathAt(difficulty));
      }
    }
  });

  test('older games keep the generic sprites and wording', () {
    const MonsterFamily? generic = null;
    expect(generic.svgPathAt(MonsterDifficulty.easy),
        'assets/icons/map_content/monster_easy.svg');
    expect(generic.label, 'Rôdeurs');
    expect(generic.monsters(1), '1 monstre');
    expect(generic.weakness, isNull);
    expect(generic.rule, isNull);
  });

  test('every family names its monsters, its rule and its answer', () {
    expect(MonsterFamily.swarm.monsters(30), '30 Dents-de-verre');
    expect(MonsterFamily.hunter.monsters(1), '1 Calmar-chasseur');
    for (final MonsterFamily family in MonsterFamily.values) {
      expect(family.rule, isNotNull);
      expect(family.weakness, isNotNull);
    }
  });
}

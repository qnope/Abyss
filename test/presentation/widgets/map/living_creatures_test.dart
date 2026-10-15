import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_family.dart';
import 'package:abyss/presentation/extensions/cell_content_type_extensions.dart';
import 'package:abyss/presentation/extensions/monster_family_extensions.dart';
import 'package:abyss/presentation/widgets/map/living_creatures.dart';
import 'package:abyss/presentation/widgets/map/map_cell_visual.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the kraken and every hard lair are living creatures', () {
    expect(isLivingCreature(krakenSvgPath), isTrue);
    expect(isLivingCreature(MonsterDifficulty.hard.svgPath), isTrue);
    for (final family in MonsterFamily.values) {
      expect(isLivingCreature(family.svgPathAt(MonsterDifficulty.hard)),
          isTrue, reason: family.name);
    }
  });

  test('easier lairs and other contents only bob', () {
    for (final difficulty in [MonsterDifficulty.easy, MonsterDifficulty.medium]) {
      expect(isLivingCreature(difficulty.svgPath), isFalse);
      expect(isLivingCreature(
          MonsterFamily.swarm.svgPathAt(difficulty)), isFalse);
    }
    expect(isLivingCreature(playerBaseSvgPath), isFalse);
    expect(isLivingCreature(null), isFalse);
  });

  test('one creature per family, the generic monsters included', () {
    expect(livingCreatureSprites, hasLength(MonsterFamily.values.length + 1));
  });
}

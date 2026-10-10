import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_family.dart';
import 'package:abyss/domain/map/monster_lair.dart';
import 'package:abyss/presentation/extensions/monster_lair_extensions.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/l10n_fixtures.dart';

void main() {
  const lair = MonsterLair(
    difficulty: MonsterDifficulty.medium,
    unitCount: 40,
    family: MonsterFamily.swarm,
    secondFamily: MonsterFamily.hunter,
    secondCount: 12,
  );

  test('names every group of the wave with its level', () {
    expect(lair.waveLabel(fr),
        '40 Dents-de-verre et 12 Calmars-chasseurs niv. 2');
    expect(lair.waveLabel(en), '40 Glassfangs and 12 Hunter Squids lv. 2');
    expect(lair.waveLabel(es),
        '40 Dientes de vidrio y 12 Calamares cazadores niv. 2');
  });

  test('lists what the wave is weak against', () {
    expect(lair.weaknessLabel(fr), 'Faibles contre : Harponneurs, Gardiens');
    expect(lair.weaknessLabel(en), 'Weak against: Harpooners, Guardians');
    expect(lair.weaknessLabel(es), 'Débiles contra: Arponeros, Guardianes');
  });

  test('has no weakness without a family', () {
    const plain = MonsterLair(difficulty: MonsterDifficulty.easy, unitCount: 3);
    expect(plain.weaknessLabel(fr), isNull);
    expect(plain.waveLabel(fr), '3 monstres niv. 1');
  });
}

import 'package:abyss/domain/game/difficulty.dart';
import 'package:abyss/presentation/extensions/difficulty_extensions.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/l10n_fixtures.dart';

void main() {
  test('names each difficulty in each language', () {
    expect(Difficulty.easy.displayName(fr), 'Facile');
    expect(Difficulty.normal.displayName(en), 'Normal');
    expect(Difficulty.hard.displayName(es), 'Difícil');
  });

  test('describes each difficulty in each language', () {
    expect(Difficulty.easy.description(fr),
        'Plus de ressources, des monstres moins nombreux.');
    expect(Difficulty.hard.description(en), 'Fewer resources, more monsters.');
    expect(Difficulty.easy.description(es), 'Más recursos, menos monstruos.');
  });
}

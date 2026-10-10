import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/event/random_event_type.dart';
import 'package:abyss/presentation/extensions/cell_content_type_extensions.dart';
import 'package:abyss/presentation/extensions/random_event_type_extensions.dart';

import '../../helpers/l10n_fixtures.dart';

void main() {
  group('CellContentTypeExtensions', () {
    test('empty has null svgPath', () {
      expect(CellContentType.empty.svgPath, isNull);
    });

    test('resourceBonus has non-null svgPath', () {
      expect(CellContentType.resourceBonus.svgPath, isNotNull);
      expect(
        CellContentType.resourceBonus.svgPath,
        contains('resource_bonus'),
      );
    });

    test('ruins has non-null svgPath', () {
      expect(CellContentType.ruins.svgPath, isNotNull);
      expect(CellContentType.ruins.svgPath, contains('ruins'));
    });

    test('monsterLair has null svgPath', () {
      expect(CellContentType.monsterLair.svgPath, isNull);
    });

    test('each content type has a non-empty label in each language', () {
      for (final l10n in [fr, en, es]) {
        for (final c in CellContentType.values) {
          expect(c.label(l10n), isNotEmpty);
        }
      }
    });

    test('names a lair in each language', () {
      expect(CellContentType.monsterLair.label(fr), 'Repaire');
      expect(CellContentType.monsterLair.label(en), 'Lair');
      expect(CellContentType.monsterLair.label(es), 'Guarida');
    });

    test('a wreck is drawn with the wreck event illustration', () {
      expect(CellContentType.wreck.label(fr), 'Épave');
      expect(CellContentType.wreck.label(es), 'Pecio');
      expect(
        CellContentType.wreck.svgPath,
        RandomEventType.wreck.illustration,
      );
    });

    test('volcanicKernel has correct label', () {
      expect(CellContentType.volcanicKernel.label(fr), 'Noyau Volcanique');
      expect(CellContentType.volcanicKernel.label(en), 'Volcanic Core');
    });

    test('volcanicKernel has correct svgPath', () {
      expect(
        CellContentType.volcanicKernel.svgPath,
        'assets/icons/terrain/volcanic_kernel.svg',
      );
    });
  });

  group('MonsterDifficultyExtensions', () {
    test('each difficulty has a valid svgPath', () {
      for (final d in MonsterDifficulty.values) {
        expect(d.svgPath, startsWith('assets/icons/map_content/'));
        expect(d.svgPath, endsWith('.svg'));
      }
    });

    test('each difficulty has a non-empty label', () {
      for (final d in MonsterDifficulty.values) {
        expect(d.label(fr), isNotEmpty);
      }
    });

    test('names the difficulty in each language', () {
      expect(MonsterDifficulty.medium.label(fr), 'Moyen');
      expect(MonsterDifficulty.medium.label(en), 'Medium');
      expect(MonsterDifficulty.hard.label(es), 'Difícil');
    });
  });
}

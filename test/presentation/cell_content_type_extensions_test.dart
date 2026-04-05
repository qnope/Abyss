import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/cell_content_type.dart';
import 'package:abyss/domain/monster_difficulty.dart';
import 'package:abyss/presentation/extensions/cell_content_type_extensions.dart';

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

    test('each content type has a non-empty label', () {
      for (final c in CellContentType.values) {
        expect(c.label, isNotEmpty);
      }
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
        expect(d.label, isNotEmpty);
      }
    });
  });
}

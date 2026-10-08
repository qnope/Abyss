import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/map/transition_base_type.dart';
import 'package:abyss/presentation/extensions/transition_base_type_extensions.dart';
import 'package:abyss/presentation/theme/abyss_colors.dart';

void main() {
  group('TransitionBaseTypeExtensions', () {
    test('faille is the passage to the depths, glowing cyan', () {
      const type = TransitionBaseType.faille;
      expect(type.displayName, 'Faille Abyssale');
      expect(type.description, 'Passage vers les profondeurs');
      expect(type.glowColor, AbyssColors.biolumCyan);
    });

    test('cheminee is the passage to the core, glowing yellow', () {
      const type = TransitionBaseType.cheminee;
      expect(type.displayName, 'Cheminee du Noyau');
      expect(type.description, 'Passage vers le noyau');
      expect(type.glowColor, AbyssColors.energyYellow);
    });

    test('each base type is visually distinct', () {
      const values = TransitionBaseType.values;
      expect(values.map((t) => t.displayName).toSet(), hasLength(values.length));
      expect(values.map((t) => t.glowColor).toSet(), hasLength(values.length));
    });
  });
}

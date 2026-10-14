import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/map/transition_base_type.dart';
import 'package:abyss/domain/map/post_holder.dart';
import 'package:abyss/presentation/extensions/post_holder_extensions.dart';
import 'package:abyss/presentation/extensions/transition_base_type_extensions.dart';

import '../../helpers/l10n_fixtures.dart';

void main() {
  group('TransitionBaseTypeExtensions', () {
    test('faille is the passage to the depths', () {
      const type = TransitionBaseType.faille;
      expect(type.displayName(fr), 'Faille Abyssale');
      expect(type.displayName(en), 'Abyssal Rift');
      expect(type.displayName(es), 'Falla abisal');
      expect(type.description(fr), 'Passage vers les profondeurs');
      expect(type.description(en), 'Passage to the depths');
    });

    test('cheminee is the passage to the core', () {
      const type = TransitionBaseType.cheminee;
      expect(type.displayName(fr), 'Cheminée du Noyau');
      expect(type.displayName(en), 'Core Vent');
      expect(type.description(fr), 'Passage vers le noyau');
      expect(type.description(es), 'Paso hacia el núcleo');
    });

    test('each base type is visually distinct', () {
      const values = TransitionBaseType.values;
      expect(values.map((t) => t.displayName(fr)).toSet(), hasLength(values.length));
      expect(values.map((t) => t.svgPathFor(PostHolder.guardians)).toSet(),
          hasLength(values.length));
    });
  });
}

import 'dart:io';

import 'package:abyss/domain/tech/tech_branch.dart';
import 'package:abyss/domain/tech/tech_option.dart';
import 'package:abyss/domain/tech/tech_tree.dart';
import 'package:abyss/presentation/extensions/tech_node_extensions.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/l10n_fixtures.dart';

/// Every node of a branch: tiers alone, choices once per option.
List<(int, TechOption?)> _nodes() => [
  for (var l = 1; l <= TechTree.maxLevel; l++)
    if (TechTree.isChoiceLevel(l))
      for (final o in TechOption.values) (l, o)
    else
      (l, null),
];

void main() {
  group('TechNodeInfo', () {
    for (final branch in TechBranch.values) {
      for (final (level, option) in _nodes()) {
        final id = '${branch.name} $level${option?.name ?? ''}';

        test('$id has a name, an effect and an existing icon', () {
          for (final l10n in [fr, en, es]) {
            expect(branch.nodeName(l10n, level, option), isNotEmpty);
            expect(branch.nodeEffect(l10n, level, option), isNotEmpty);
          }
          expect(File(branch.nodeIconPath(level, option)).existsSync(), isTrue);
        });
      }
    }

    test('icon paths follow branch, level and option', () {
      expect(TechBranch.explorer.nodeIconPath(3),
          'assets/icons/tech/explorer_3.svg');
      expect(TechBranch.military.nodeIconPath(4, TechOption.b),
          'assets/icons/tech/military_4b.svg');
    });

    test('tiers describe the +20% bonus', () {
      expect(TechBranch.military.nodeEffect(fr, 1), '+20 % ATK et DEF');
      expect(TechBranch.resources.nodeEffect(fr, 5), '+20 % de production');
      expect(TechBranch.military.nodeEffect(en, 3), '+20% ATK and DEF');
      expect(TechBranch.resources.nodeEffect(es, 1), '+20 % de producción');
    });

    test('names the nodes in each language', () {
      expect(TechBranch.explorer.nodeName(fr, 5), "Œil de l'abysse");
      expect(TechBranch.explorer.nodeName(en, 5), 'Eye of the Abyss');
      expect(TechBranch.military.nodeName(es, 2, TechOption.a),
          'Hojas de coral');
    });

    test('the explored area grows in each language', () {
      expect(TechBranch.explorer.nodeEffect(fr, 3), 'Zone explorée 7×7');
      expect(TechBranch.explorer.nodeEffect(en, 1), 'Explored area 5×5');
      expect(TechBranch.explorer.nodeEffect(es, 5), 'Zona explorada 9×9');
    });

    test('an unknown node has an empty name', () {
      expect(TechBranch.military.nodeName(fr, 2), isEmpty);
    });
  });
}

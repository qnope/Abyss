import 'dart:io';

import 'package:abyss/domain/tech/tech_branch.dart';
import 'package:abyss/domain/tech/tech_option.dart';
import 'package:abyss/domain/tech/tech_tree.dart';
import 'package:abyss/presentation/extensions/tech_node_extensions.dart';
import 'package:flutter_test/flutter_test.dart';

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
          expect(branch.nodeName(level, option), isNotEmpty);
          expect(branch.nodeEffect(level, option), isNotEmpty);
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
      expect(TechBranch.military.nodeEffect(1), '+20 % ATK et DEF');
      expect(TechBranch.resources.nodeEffect(5), '+20 % de production');
    });

    test('an unknown node has an empty name', () {
      expect(TechBranch.military.nodeName(2), isEmpty);
    });
  });
}

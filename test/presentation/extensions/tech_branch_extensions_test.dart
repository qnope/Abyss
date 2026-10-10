import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/tech/tech_branch.dart';
import 'package:abyss/presentation/extensions/tech_branch_extensions.dart';

import '../../helpers/l10n_fixtures.dart';

void main() {
  group('TechBranchExtensions', () {
    for (final branch in TechBranch.values) {
      test('${branch.name} has a name and a description in each language',
          () {
        for (final l10n in [fr, en, es]) {
          expect(branch.displayName(l10n), isNotEmpty);
          expect(branch.description(l10n), isNotEmpty);
        }
      });

      test('${branch.name} has non-empty iconPath', () {
        expect(branch.iconPath, isNotEmpty);
      });

      test('${branch.name} has a color', () {
        expect(branch.color, isNotNull);
      });
    }

    test('names the branches in each language', () {
      expect(TechBranch.military.displayName(fr), 'Militaire');
      expect(TechBranch.resources.displayName(en), 'Resources');
      expect(TechBranch.military.displayName(es), 'Militar');
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/tech/tech_branch.dart';
import 'package:abyss/presentation/extensions/tech_branch_extensions.dart';

void main() {
  group('TechBranchExtensions', () {
    for (final branch in TechBranch.values) {
      test('${branch.name} has non-empty displayName', () {
        expect(branch.displayName, isNotEmpty);
      });

      test('${branch.name} has non-empty description', () {
        expect(branch.description, isNotEmpty);
      });

      test('${branch.name} has non-empty iconPath', () {
        expect(branch.iconPath, isNotEmpty);
      });

      test('${branch.name} has a color', () {
        expect(branch.color, isNotNull);
      });
    }
  });
}

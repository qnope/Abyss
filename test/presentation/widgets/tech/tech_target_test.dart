import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/tech/tech_branch.dart';
import 'package:abyss/presentation/widgets/tech/tech_target.dart';

void main() {
  group('TechTarget', () {
    test('equal when branch and level match', () {
      expect(const TechTarget(TechBranch.explorer, 2),
        const TechTarget(TechBranch.explorer, 2));
    });

    test('branch target differs from its nodes', () {
      expect(const TechTarget(TechBranch.explorer),
        isNot(const TechTarget(TechBranch.explorer, 1)));
    });
  });
}

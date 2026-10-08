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

    test('targets on different branches differ', () {
      expect(const TechTarget(TechBranch.explorer, 1),
        isNot(const TechTarget(TechBranch.military, 1)));
    });

    test('never equals an object of another type', () {
      // ignore: unrelated_type_equality_checks
      expect(const TechTarget(TechBranch.explorer) == TechBranch.explorer,
        isFalse);
    });

    test('equal targets share a hash code and dedupe in a set', () {
      // Non-const instances so identity cannot be the reason they match.
      final a = TechTarget(TechBranch.military, 3);
      final b = TechTarget(TechBranch.military, 3);
      expect(identical(a, b), isFalse);
      expect(a.hashCode, b.hashCode);
      expect({a, b, TechTarget(TechBranch.military)}, hasLength(2));
    });

    test('level defaults to null for a whole-branch target', () {
      expect(const TechTarget(TechBranch.explorer).level, isNull);
    });
  });
}

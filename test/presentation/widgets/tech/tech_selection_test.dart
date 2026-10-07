import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/tech/tech_branch.dart';
import 'package:abyss/presentation/widgets/tech/tech_selection.dart';

void main() {
  group('TechSelection.next', () {
    test('branch moves to its first node', () {
      expect(const TechSelection(TechBranch.explorer).next,
        const TechSelection(TechBranch.explorer, 1));
    });

    test('node moves to the following one', () {
      expect(const TechSelection(TechBranch.explorer, 2).next,
        const TechSelection(TechBranch.explorer, 3));
    });

    test('last node stays put', () {
      expect(const TechSelection(TechBranch.explorer, 5).next,
        const TechSelection(TechBranch.explorer, 5));
    });
  });
}

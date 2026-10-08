import 'package:abyss/domain/tech/tech_branch.dart';
import 'package:abyss/domain/tech/tech_option.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/tech_helpers.dart';

int _side(int level, {List<TechOption> options = const []}) => effectsOf([
  researchedBranch(TechBranch.explorer, level, options: options),
]).revealSide;

void main() {
  group('reveal side by explorer research', () {
    test('locked explorer branch reveals a 3x3 square', () {
      expect(effectsOf(const []).revealSide, 3);
    });

    test('each tier (levels 1, 3, 5) widens the side by 2', () {
      expect(_side(0), 3);
      expect(_side(1), 5);
      expect(_side(2, options: [TechOption.b]), 5);
      expect(_side(3, options: [TechOption.b]), 7);
      expect(_side(5, options: [TechOption.b, TechOption.a]), 9);
    });

    test('Sonar profond (level 2 option A) adds 2 more', () {
      expect(_side(2, options: [TechOption.a]), 7);
      expect(_side(5, options: [TechOption.a, TechOption.a]), 11);
    });

    test('an old save without choices defaults to Sonar', () {
      expect(_side(2), 7);
    });
  });
}

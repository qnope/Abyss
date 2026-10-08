import 'package:abyss/domain/tech/tech_tree.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TechTree', () {
    test('a branch has five levels', () {
      expect(TechTree.maxLevel, 5);
    });

    test('only levels 2 and 4 hold a choice', () {
      final choices = [
        for (var l = 0; l <= 6; l++)
          if (TechTree.isChoiceLevel(l)) l,
      ];
      expect(choices, [2, 4]);
    });

    test('choice levels are indexed in order', () {
      expect(TechTree.choiceIndex(2), 0);
      expect(TechTree.choiceIndex(4), 1);
    });

    test('tiers reached count the odd levels researched', () {
      expect(
        [for (var l = 0; l <= 5; l++) TechTree.tiersReached(l)],
        [0, 1, 1, 2, 2, 3],
      );
    });
  });
}

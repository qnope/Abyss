import 'package:abyss/domain/map/transition_base_type.dart';
import 'package:abyss/domain/script/strategies/scout_descent_moves.dart';
import 'package:abyss/domain/script/strategies/scout_moves.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/deep_scout_helper.dart';

DeepScouts _holding(List<TransitionBaseType> posts, {int home = 10}) {
  final deep = DeepScouts();
  posts.forEach(deep.hold);
  deep.put(1, home);
  return deep;
}

void main() {
  const both = [TransitionBaseType.faille, TransitionBaseType.cheminee];

  group('deepestReachable', () {
    test('is the base level without a Faille', () {
      expect(DeepScouts().turn().deepestReachable(), 1);
    });

    test('goes one level down per held post with its passage', () {
      expect(_holding([TransitionBaseType.faille]).turn().deepestReachable(),
          2);
      expect(_holding(both).turn().deepestReachable(), 3);
    });
  });

  group('sendScoutsDown', () {
    test('takes scouts from the base to level 3 in the same turn', () {
      final deep = _holding(both);
      deep.turn().sendScoutsDown(6);
      expect(deep.scouts(3), 6);
      expect(deep.scouts(2), 0);
      expect(deep.scouts(1), 4);
    });

    test('stops at level 2 while only the Faille is held', () {
      final deep = _holding([TransitionBaseType.faille]);
      deep.turn().sendScoutsDown(6);
      expect(deep.scouts(2), 6);
      expect(deep.scouts(1), 4);
    });

    test('only tops the deep level up', () {
      final deep = _holding(both);
      deep.put(3, 4);
      deep.put(2, 1);
      deep.turn().sendScoutsDown(6);
      expect(deep.scouts(3), 6);
      expect(deep.scouts(2), 0, reason: 'the scout on the way goes first');
      expect(deep.scouts(1), 9);
    });

    test('sends nothing when the deep level has enough', () {
      final deep = _holding(both);
      deep.put(3, 6);
      deep.turn().sendScoutsDown(6);
      expect(deep.scouts(1), 10);
    });
  });

  group('once the road is seen there', () {
    test('no scout goes ahead to a volcano already seen', () {
      final deep = _holding(both);
      deep.faction.addRevealedCell(3, deep.kernel.first);
      deep.turn().sendScoutsDown(6);
      expect(deep.scouts(3), 0);
      expect(deep.turn().scoutsMissingBelow(6), 0);
    });

    test('nor to a level 2 whose Cheminée is seen', () {
      final deep = _holding([TransitionBaseType.faille]);
      final cheminee = deep.cells(
          2, (c) => c.transitionBase?.type == TransitionBaseType.cheminee);
      deep.faction.addRevealedCell(2, cheminee.first);
      deep.put(2, 0);
      deep.turn().sendScoutsDown(6);
      expect(deep.scouts(2), 0);
    });
  });

  group('scoutsWanted', () {
    test('keeps the expedition scouts home for the army', () {
      final deep = _holding(both);
      deep.put(3, 4);
      expect(deep.turn().scoutsWanted(explorers: 2, deepScouts: 6), 8);
    });

    test('ahead of the army, only what is missing below', () {
      final deep = _holding(both);
      deep.put(3, 4);
      final turn = deep.turn();
      expect(turn.scoutsWanted(explorers: 2, deepScouts: 6, scoutsAhead: true),
          4);
      expect(turn.scoutsMissingBelow(6), 2);
    });
  });

  group('scout', () {
    test('sends scouts down ahead of the army when asked', () {
      final deep = _holding(both);
      deep.turn().scout(explorers: 2, deepScouts: 6, scoutsAhead: true);
      expect(deep.scouts(3) + deep.targets(3).length, 6);
    });

    test('keeps them home otherwise', () {
      final deep = _holding(both);
      deep.turn().scout(explorers: 2, deepScouts: 6);
      expect(deep.scouts(3), 0);
    });
  });
}

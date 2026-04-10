import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/unit/unit_type.dart';

import 'send_reinforcements_helper.dart';

void main() {
  group('SendReinforcementsAction validate', () {
    test('succeeds with valid conditions', () {
      final s = createReinforcementScenario();
      final result =
          createReinforcementAction().validate(s.game, s.player);
      expect(result.isSuccess, isTrue);
    });

    test('fails when map is missing', () {
      final s = createReinforcementScenario();
      s.game.levels = {};
      final result =
          createReinforcementAction().validate(s.game, s.player);
      expect(result.isSuccess, isFalse);
      expect(result.reason, 'Carte non generee');
    });

    test('fails when cell has no transition base', () {
      final s = createReinforcementScenario();
      s.game.levels[1] = buildReinforcementMap();
      final result =
          createReinforcementAction().validate(s.game, s.player);
      expect(result.isSuccess, isFalse);
      expect(result.reason, 'Pas de base de transition');
    });

    test('fails when base not captured by player', () {
      final s = createReinforcementScenario(capturedBy: 'other');
      final result =
          createReinforcementAction().validate(s.game, s.player);
      expect(result.isSuccess, isFalse);
      expect(result.reason, 'Base non capturee');
    });

    test('fails when target level not generated', () {
      final s =
          createReinforcementScenario(withTargetLevel: false);
      final result =
          createReinforcementAction().validate(s.game, s.player);
      expect(result.isSuccess, isFalse);
      expect(result.reason, 'Niveau cible non explore');
    });

    test('fails when no units selected', () {
      final s = createReinforcementScenario();
      final action = createReinforcementAction(units: {});
      final result = action.validate(s.game, s.player);
      expect(result.isSuccess, isFalse);
      expect(result.reason, 'Aucune unite selectionnee');
    });

    test('fails with insufficient units', () {
      final s = createReinforcementScenario(scoutCount: 2);
      final result =
          createReinforcementAction().validate(s.game, s.player);
      expect(result.isSuccess, isFalse);
      expect(result.reason, 'Unites insuffisantes');
    });
  });

  group('SendReinforcementsAction execute', () {
    test('subtracts units from source level', () {
      final s = createReinforcementScenario();
      createReinforcementAction().execute(s.game, s.player);
      expect(
        s.player.unitsOnLevel(1)[UnitType.scout]!.count,
        2,
      );
    });

    test('creates pending reinforcement order', () {
      final s = createReinforcementScenario();
      createReinforcementAction().execute(s.game, s.player);
      expect(s.player.pendingReinforcements, hasLength(1));

      final order = s.player.pendingReinforcements.first;
      expect(order.fromLevel, 1);
      expect(order.toLevel, 2);
      expect(order.units, {UnitType.scout: 3});
      expect(order.departTurn, 1);
      expect(order.arrivalPoint.x, 2);
      expect(order.arrivalPoint.y, 2);
    });

    test('returns failure on invalid input', () {
      final s = createReinforcementScenario(scoutCount: 0);
      final result =
          createReinforcementAction().execute(s.game, s.player);
      expect(result.isSuccess, isFalse);
    });
  });
}

import 'package:abyss/domain/action/fight_monster_action.dart';
import 'package:abyss/domain/action/fight_monster_result.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fight_monster_action_helper.dart';

void main() {
  group('FightMonsterAction validate', () {
    test('fails when map is null', () {
      final player = buildFightTestPlayer(stock: {UnitType.harpoonist: 5});
      final game = Game(
        humanPlayerId: player.id,
        players: {player.id: player},
      );
      final action = FightMonsterAction(
        targetX: 1,
        targetY: 1,
        selectedUnits: {UnitType.harpoonist: 1},
      );
      final result = action.validate(game, player);
      expect(result.isSuccess, isFalse);
      expect(result.reason, 'Carte non générée');
      expect(result, isA<FightMonsterResult>());
    });

    test('fails when cell is not a monster lair', () {
      final scenario = createFightScenario(
        content: CellContentType.empty,
        withLair: false,
        stock: {UnitType.harpoonist: 5},
      );
      final action = FightMonsterAction(
        targetX: 1,
        targetY: 1,
        selectedUnits: {UnitType.harpoonist: 1},
      );
      final result = action.validate(scenario.game, scenario.player);
      expect(result.isSuccess, isFalse);
      expect(result.reason, 'Pas de monstre ici');
    });

    test('fails when cell is already collected', () {
      final scenario = createFightScenario(
        collectedBy: 'test-uuid',
        stock: {UnitType.harpoonist: 5},
      );
      final action = FightMonsterAction(
        targetX: 1,
        targetY: 1,
        selectedUnits: {UnitType.harpoonist: 1},
      );
      final result = action.validate(scenario.game, scenario.player);
      expect(result.isSuccess, isFalse);
      expect(result.reason, 'Tanière déjà vaincue');
    });

    test('fails when lair data is missing', () {
      final scenario = createFightScenario(
        withLair: false,
        stock: {UnitType.harpoonist: 5},
      );
      final action = FightMonsterAction(
        targetX: 1,
        targetY: 1,
        selectedUnits: {UnitType.harpoonist: 1},
      );
      final result = action.validate(scenario.game, scenario.player);
      expect(result.isSuccess, isFalse);
      // content defaults to monsterLair -> falls through to lair null
      expect(result.reason, 'Tanière vide');
    });

    test('fails when selected count exceeds stock', () {
      final scenario = createFightScenario(
        stock: {UnitType.harpoonist: 2},
      );
      final action = FightMonsterAction(
        targetX: 1,
        targetY: 1,
        selectedUnits: {UnitType.harpoonist: 10},
      );
      final result = action.validate(scenario.game, scenario.player);
      expect(result.isSuccess, isFalse);
      expect(result.reason, 'Unités insuffisantes');
    });

    test('fails on all-zero selection', () {
      final scenario = createFightScenario(
        stock: {UnitType.harpoonist: 5},
      );
      final action = FightMonsterAction(
        targetX: 1,
        targetY: 1,
        selectedUnits: {UnitType.harpoonist: 0},
      );
      final result = action.validate(scenario.game, scenario.player);
      expect(result.isSuccess, isFalse);
      expect(result.reason, 'Aucune unité sélectionnée');
    });

    test('fails on empty selection', () {
      final scenario = createFightScenario(
        stock: {UnitType.harpoonist: 5},
      );
      final action = FightMonsterAction(
        targetX: 1,
        targetY: 1,
        selectedUnits: const {},
      );
      final result = action.validate(scenario.game, scenario.player);
      expect(result.isSuccess, isFalse);
      expect(result.reason, 'Aucune unité sélectionnée');
    });

    test('succeeds on happy path', () {
      final scenario = createFightScenario(
        stock: {UnitType.harpoonist: 5},
      );
      final action = FightMonsterAction(
        targetX: 1,
        targetY: 1,
        selectedUnits: {UnitType.harpoonist: 2},
      );
      final result = action.validate(scenario.game, scenario.player);
      expect(result.isSuccess, isTrue);
    });
  });
}

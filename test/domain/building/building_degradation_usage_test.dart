import 'package:abyss/domain/action/action_failure.dart';
import 'package:abyss/domain/action/descend_validator.dart';
import 'package:abyss/domain/action/garrison_kernel_action.dart';
import 'package:abyss/domain/action/recruit_unit_action.dart';
import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/building/coral_citadel_rampart.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/game_status.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/game/victory_checker.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/unit/unit_cost_calculator.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../action/descend_action_helper.dart';
import '../volcano/volcano_test_helper.dart';

Map<BuildingType, Building> _base(int hq, Map<BuildingType, int> levels) => {
  BuildingType.headquarters: Building(
    type: BuildingType.headquarters,
    level: hq,
  ),
  for (final e in levels.entries) e.key: Building(type: e.key, level: e.value),
};

void main() {
  group('degraded barracks doubles the unit cost', () {
    test('cost x2', () {
      final calc = UnitCostCalculator();
      for (final t in UnitType.values) {
        final normal = calc.recruitmentCost(t);
        final doubled = calc.recruitmentCost(t, degraded: true);
        expect(doubled, {for (final e in normal.entries) e.key: e.value * 2});
      }
    });

    Player player(int hq, {int algae = 25}) =>
        Player(
            id: 'p',
            name: 'P',
            buildings: _base(hq, {BuildingType.barracks: 1}),
          )
          ..resources[ResourceType.algae]!.amount = algae
          ..resources[ResourceType.coral]!.amount = 100;

    test('recruiting charges twice, and refuses without the funds', () {
      final p = player(1, algae: 25);
      final game = Game(humanPlayerId: 'p', players: {'p': p});
      final action = RecruitUnitAction(unitType: UnitType.scout, quantity: 2);
      // 2 scouts = 40 algae when doubled.
      expect(action.validate(game, p).reason, ActionFailure.notEnoughResources);
      p.resources[ResourceType.algae]!.amount = 40;
      expect(action.execute(game, p).isSuccess, isTrue);
      expect(p.resources[ResourceType.algae]!.amount, 0);
    });

    test('with the QG at 2 the cost is normal', () {
      final p = player(2, algae: 20);
      final game = Game(humanPlayerId: 'p', players: {'p': p});
      final action = RecruitUnitAction(unitType: UnitType.scout, quantity: 2);
      expect(action.execute(game, p).isSuccess, isTrue);
      expect(p.resources[ResourceType.algae]!.amount, 0);
    });
  });

  group('degraded Citadel halves the rampart', () {
    test('combatant', () {
      final normal = CoralCitadelRampart.combatantFor(3)!;
      final half = CoralCitadelRampart.combatantFor(3, degraded: true)!;
      expect(half.maxHp, normal.maxHp ~/ 2);
      expect(half.def, normal.def ~/ 2);
      expect(CoralCitadelRampart.combatantFor(0, degraded: true), isNull);
    });

    test('of the buildings of a base', () {
      final ok = _base(7, {BuildingType.coralCitadel: 3});
      final low = _base(6, {BuildingType.coralCitadel: 3});
      expect(CoralCitadelRampart.combatantOf(ok)!.maxHp, 120);
      expect(CoralCitadelRampart.combatantOf(low)!.maxHp, 60);
      expect(CoralCitadelRampart.combatantOf(_base(7, {})), isNull);
    });
  });

  group('Module, Capsule and Noyau are unusable when degraded', () {
    test('descent refused with a Module the QG no longer supports', () {
      final s = createDescendScenario();
      s.player.buildings[BuildingType.headquarters] = Building(
        type: BuildingType.headquarters,
        level: 4,
      );
      final result = DescendValidator.validate(
        game: s.game,
        player: s.player,
        transitionX: 5,
        transitionY: 5,
        fromLevel: 1,
        selectedUnits: {UnitType.scout: 1},
      );
      expect(result.reason, ActionFailure.requiredBuildingDegraded);
      s.player.buildings[BuildingType.headquarters]!.level = 5;
      expect(
        DescendValidator.validate(
          game: s.game,
          player: s.player,
          transitionX: 5,
          transitionY: 5,
          fromLevel: 1,
          selectedUnits: {UnitType.scout: 1},
        ).isSuccess,
        isTrue,
      );
    });

    test('garrison refused with a degraded Noyau, allowed otherwise', () {
      final p = volcanoPlayer(kernelLevel: 3, onVolcano: {UnitType.scout: 2});
      p.buildings[BuildingType.headquarters]!.level = 9;
      final game = volcanoGame(p);
      final action = GarrisonKernelAction(selectedUnits: {UnitType.scout: 1});
      expect(action.validate(game, p).reason, ActionFailure.kernelDegraded);
      expect(action.execute(game, p).isSuccess, isFalse);
      p.buildings[BuildingType.headquarters]!.level = 10;
      expect(action.execute(game, p).isSuccess, isTrue);
    });

    test('units can still leave a degraded garrison', () {
      final p = volcanoPlayer(kernelLevel: 3, garrison: {UnitType.scout: 2});
      p.buildings[BuildingType.headquarters]!.level = 9;
      final out = GarrisonKernelAction(
        selectedUnits: {UnitType.scout: 1},
        withdraw: true,
      );
      expect(out.validate(volcanoGame(p), p).isSuccess, isTrue);
    });
  });

  group('victory needs an undegraded Noyau 10', () {
    Game game(int hq) {
      final p = Player(
        id: 'h',
        name: 'H',
        buildings: _base(hq, {BuildingType.volcanicKernel: 10}),
      );
      return Game(humanPlayerId: 'h', players: {'h': p});
    }

    test('refused when the QG fell below 10', () {
      expect(VictoryChecker.check(game(9)), isNull);
    });

    test('granted with the QG at 10', () {
      expect(VictoryChecker.check(game(10)), GameStatus.victory);
    });

    test('a faction with a degraded Noyau does not defeat the human', () {
      final h = Player(id: 'h', name: 'H');
      final f = Player(
        id: 'f',
        name: 'F',
        buildings: _base(8, {BuildingType.volcanicKernel: 10}),
      );
      final g = Game(humanPlayerId: 'h', players: {'h': h, 'f': f});
      expect(VictoryChecker.check(g), isNull);
    });
  });
}

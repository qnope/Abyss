import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/faction/base_intel.dart';
import 'package:abyss/domain/faction/post_defence.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/map/reinforcement_order.dart';
import 'package:abyss/domain/map/transition_base_type.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/post_attack_helper.dart';

BaseIntel _report(int turn, Map<UnitType, int> army) => BaseIntel(
  turn: turn,
  headquartersLevel: 3,
  rampartLevel: 0,
  army: army,
  stocks: const {},
);

ReinforcementOrder _order(int toLevel, Map<UnitType, int> units) =>
    ReinforcementOrder(
      fromLevel: toLevel - 1,
      toLevel: toLevel,
      units: units,
      departTurn: 11,
      arrivalPoint: GridPosition(x: 0, y: 0),
    );

PostDefence _of(PostWar war) => PostDefence.of(war.game, war.human, war.post);

void main() {
  group('PostDefence threat', () {
    late PostWar war;
    late Player first;
    late Player second;

    setUp(() {
      war = PostWar(TransitionBaseType.faille, humanHolds: true);
      first = war.game.players[war.game.factions[0].id]!;
      second = war.game.players[war.game.factions[1].id]!;
    });

    test('is unknown without any scouting report', () {
      expect(_of(war).threat, isNull);
    });

    test('is the faction whose reported army is the largest', () {
      war.human.intel[first.id] = _report(9, {UnitType.harpoonist: 12});
      war.human.intel[second.id] = _report(10, {
        UnitType.harpoonist: 20,
        UnitType.guardian: 15,
      });

      final PostThreat threat = _of(war).threat!;

      expect(threat.faction.id, second.id);
      expect(threat.faction.name, war.game.factions[1].name);
      expect(threat.units, 35);
      expect(threat.reportTurn, 10);
      expect(threat.turnsAgo, 2);
    });

    test('keeps a stale report, telling how old it is', () {
      war.human.intel[first.id] = _report(1, {UnitType.harpoonist: 4});

      final PostThreat threat = _of(war).threat!;

      expect(threat.reportTurn, 1);
      expect(threat.turnsAgo, 11);
    });

    test('ignores a faction that has fallen', () {
      war.human.intel[first.id] = _report(9, {UnitType.harpoonist: 4});
      war.human.intel[second.id] = _report(9, {UnitType.harpoonist: 40});
      second.savedFallen = true;

      expect(_of(war).threat!.faction.id, first.id);
    });

    test('ignores a report of an empty base', () {
      war.human.intel[first.id] = _report(9, {UnitType.harpoonist: 0});

      expect(_of(war).threat, isNull);
    });

    test('is unknown on a Cheminée, the reports being of level 1', () {
      final cheminee = PostWar(TransitionBaseType.cheminee, humanHolds: true);
      cheminee.human.intel[cheminee.game.factions[0].id] = _report(9, {
        UnitType.harpoonist: 30,
      });

      expect(_of(cheminee).threat, isNull);
    });
  });

  group('PostDefence losses', () {
    test('name the passage building of a Faille', () {
      final war = PostWar(TransitionBaseType.faille, humanHolds: true);

      expect(_of(war).passage, BuildingType.descentModule);
    });

    test('name the passage building of a Cheminée', () {
      final war = PostWar(TransitionBaseType.cheminee, humanHolds: true);

      expect(_of(war).passage, BuildingType.pressureCapsule);
    });

    test('name no passage building while it is at level 0', () {
      final war = PostWar(TransitionBaseType.faille, humanHolds: true);
      war.human.buildings[BuildingType.descentModule]!.level = 0;

      expect(_of(war).passage, isNull);
    });

    test('count the units on the level below', () {
      final war = PostWar(TransitionBaseType.faille, humanHolds: true);
      war.put(war.human, 2, {UnitType.harpoonist: 7, UnitType.guardian: 5});
      war.put(war.human, 1, {UnitType.harpoonist: 30});

      expect(_of(war).unitsBelow, 12);
    });

    test('are zero units below when nobody stands there', () {
      final war = PostWar(TransitionBaseType.cheminee, humanHolds: true);

      expect(_of(war).unitsBelow, 0);
      expect(_of(war).reinforcements, 0);
    });

    test('count the reinforcements heading to the level below', () {
      final war = PostWar(TransitionBaseType.faille, humanHolds: true);
      war.human.pendingReinforcements
        ..add(_order(2, {UnitType.harpoonist: 2}))
        ..add(_order(2, {UnitType.guardian: 1}))
        ..add(_order(3, {UnitType.harpoonist: 9}));

      expect(_of(war).reinforcements, 3);
    });
  });
}

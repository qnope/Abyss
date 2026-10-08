import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/cheat_codes.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/tech/tech_branch.dart';
import 'package:abyss/domain/unit/unit_type.dart';

Player _player(String name) => Player(name: name);

void main() {
  group('CheatCodes.apply with the cheat name', () {
    late Player player;

    setUp(() {
      player = _player('qnope');
      CheatCodes.apply(player);
    });

    test('fills every resource to 5000', () {
      for (final resource in player.resources.values) {
        expect(resource.amount, 5000, reason: resource.type.name);
      }
    });

    test('raises the headquarters to 7 and core buildings to 3', () {
      expect(player.buildings[BuildingType.headquarters]!.level, 7);
      for (final type in const [
        BuildingType.algaeFarm,
        BuildingType.coralMine,
        BuildingType.oreExtractor,
        BuildingType.solarPanel,
        BuildingType.laboratory,
        BuildingType.barracks,
      ]) {
        expect(player.buildings[type]?.level, 3, reason: type.name);
      }
    });

    test('unlocks every tech branch at research level 3', () {
      for (final branch in TechBranch.values) {
        final state = player.techBranches[branch]!;
        expect(state.unlocked, isTrue, reason: branch.name);
        expect(state.researchLevel, 3, reason: branch.name);
      }
    });

    test('stocks the base with scouts, harpoonists and admirals', () {
      final units = player.unitsOnLevel(1);
      expect(units[UnitType.scout]!.count, 200);
      expect(units[UnitType.harpoonist]!.count, 200);
      expect(units[UnitType.abyssAdmiral]!.count, 10);
    });
  });

  test('skips branches the player does not track', () {
    final player = Player(name: 'qnope', techBranches: {});
    CheatCodes.apply(player);
    expect(player.techBranches, isEmpty);
  });

  test('any other name leaves the player untouched', () {
    final player = _player('Nemo');
    final before = _player('Nemo');
    CheatCodes.apply(player);

    for (final type in player.resources.keys) {
      expect(player.resources[type]!.amount, before.resources[type]!.amount);
    }
    for (final type in player.buildings.keys) {
      expect(player.buildings[type]!.level, before.buildings[type]!.level);
    }
    for (final state in player.techBranches.values) {
      expect(state.unlocked, isFalse);
      expect(state.researchLevel, 0);
    }
    expect(player.unitsOnLevel(1)[UnitType.scout]?.count ?? 0,
        before.unitsOnLevel(1)[UnitType.scout]?.count ?? 0);
  });

  test('the cheat name is case sensitive', () {
    final player = _player('QNOPE');
    CheatCodes.apply(player);
    expect(player.resources.values.map((r) => r.amount), isNot(contains(5000)));
  });
}

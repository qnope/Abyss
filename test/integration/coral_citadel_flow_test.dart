import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/action/upgrade_building_action.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/resource/resource.dart';
import 'package:abyss/domain/resource/resource_type.dart';

void main() {
  ({Game game, Player player}) buildScenario({required int hqLevel}) {
    final player = Player(id: 'human', name: 'Nemo');
    player.buildings[BuildingType.headquarters]!.level = hqLevel;
    player.resources[ResourceType.coral] =
        Resource(type: ResourceType.coral, amount: 2000, maxStorage: 5000);
    player.resources[ResourceType.ore] =
        Resource(type: ResourceType.ore, amount: 2000, maxStorage: 5000);
    player.resources[ResourceType.energy] =
        Resource(type: ResourceType.energy, amount: 1000, maxStorage: 1000);
    player.resources[ResourceType.pearl] =
        Resource(type: ResourceType.pearl, amount: 100, maxStorage: 100);
    final game = Game.singlePlayer(player);
    return (game: game, player: player);
  }

  test('full coral citadel construction + upgrade flow', () {
    final s = buildScenario(hqLevel: 3);
    final player = s.player;
    final game = s.game;
    final action = UpgradeBuildingAction(
      buildingType: BuildingType.coralCitadel,
    );

    final coralBefore = player.resources[ResourceType.coral]!.amount;
    final oreBefore = player.resources[ResourceType.ore]!.amount;
    final energyBefore = player.resources[ResourceType.energy]!.amount;
    final pearlBefore = player.resources[ResourceType.pearl]!.amount;

    final firstResult = action.execute(game, player);
    expect(firstResult.isSuccess, isTrue);
    expect(player.buildings[BuildingType.coralCitadel]!.level, 1);
    expect(player.resources[ResourceType.coral]!.amount, coralBefore - 120);
    expect(player.resources[ResourceType.ore]!.amount, oreBefore - 120);
    expect(player.resources[ResourceType.energy]!.amount, energyBefore - 60);
    expect(player.resources[ResourceType.pearl]!.amount, pearlBefore - 5);

    // Bump HQ to 5 to allow level 2.
    player.buildings[BuildingType.headquarters]!.level = 5;

    final coralBefore2 = player.resources[ResourceType.coral]!.amount;
    final oreBefore2 = player.resources[ResourceType.ore]!.amount;
    final energyBefore2 = player.resources[ResourceType.energy]!.amount;
    final pearlBefore2 = player.resources[ResourceType.pearl]!.amount;

    final secondResult = action.execute(game, player);
    expect(secondResult.isSuccess, isTrue);
    expect(player.buildings[BuildingType.coralCitadel]!.level, 2);
    expect(player.resources[ResourceType.coral]!.amount, coralBefore2 - 240);
    expect(player.resources[ResourceType.ore]!.amount, oreBefore2 - 240);
    expect(player.resources[ResourceType.energy]!.amount, energyBefore2 - 120);
    expect(player.resources[ResourceType.pearl]!.amount, pearlBefore2 - 10);

    // Level 3 requires HQ 7, still at 5 — must fail, no state change.
    final coralBefore3 = player.resources[ResourceType.coral]!.amount;
    final oreBefore3 = player.resources[ResourceType.ore]!.amount;
    final energyBefore3 = player.resources[ResourceType.energy]!.amount;
    final pearlBefore3 = player.resources[ResourceType.pearl]!.amount;

    final validation = action.validate(game, player);
    expect(validation.isSuccess, isFalse);
    final thirdResult = action.execute(game, player);
    expect(thirdResult.isSuccess, isFalse);
    expect(player.buildings[BuildingType.coralCitadel]!.level, 2);
    expect(player.resources[ResourceType.coral]!.amount, coralBefore3);
    expect(player.resources[ResourceType.ore]!.amount, oreBefore3);
    expect(player.resources[ResourceType.energy]!.amount, energyBefore3);
    expect(player.resources[ResourceType.pearl]!.amount, pearlBefore3);
  });
}

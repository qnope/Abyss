import 'package:abyss/domain/action/research_tech_action.dart';
import 'package:abyss/domain/action/upgrade_building_action.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/tech/tech_branch.dart';
import 'package:abyss/domain/turn/player_turn_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

({Game game, Player player}) _scenario({int hqLevel = 1}) {
  final player = Player(name: 'Test');
  for (final resource in player.resources.values) {
    resource.amount = resource.maxStorage;
  }
  player.buildings[BuildingType.headquarters]!.level = hqLevel;
  player.buildings[BuildingType.laboratory]!.level = 2;
  player.techBranches[TechBranch.military]!.unlocked = true;
  player.techBranches[TechBranch.resources]!.unlocked = true;
  final game = Game(humanPlayerId: player.id, players: {player.id: player});
  return (game: game, player: player);
}

UpgradeBuildingAction _upgrade(BuildingType type) =>
    UpgradeBuildingAction(buildingType: type);

void main() {
  test('a single building site below HQ 5', () {
    final s = _scenario();
    expect(_upgrade(BuildingType.algaeFarm).execute(s.game, s.player)
        .isSuccess, isTrue);
    final second = _upgrade(BuildingType.coralMine).execute(s.game, s.player);
    expect(second.isSuccess, isFalse);
    expect(second.reason, 'Chantiers occupes ce tour');
  });

  test('two building sites from HQ 5', () {
    final s = _scenario(hqLevel: 5);
    expect(_upgrade(BuildingType.algaeFarm).execute(s.game, s.player)
        .isSuccess, isTrue);
    expect(_upgrade(BuildingType.coralMine).execute(s.game, s.player)
        .isSuccess, isTrue);
    expect(_upgrade(BuildingType.solarPanel).execute(s.game, s.player)
        .isSuccess, isFalse);
  });

  test('one research per turn', () {
    final s = _scenario();
    expect(ResearchTechAction(branch: TechBranch.military)
        .execute(s.game, s.player).isSuccess, isTrue);
    final second = ResearchTechAction(branch: TechBranch.resources)
        .execute(s.game, s.player);
    expect(second.isSuccess, isFalse);
    expect(second.reason, 'Recherche deja lancee ce tour');
  });

  test('the end of the turn frees the sites and the laboratory', () {
    final s = _scenario();
    _upgrade(BuildingType.algaeFarm).execute(s.game, s.player);
    ResearchTechAction(branch: TechBranch.military).execute(s.game, s.player);
    PlayerTurnResolver.resolve(s.player, 1);
    expect(s.player.worksite.upgrades, 0);
    expect(s.player.worksite.canResearch, isTrue);
    expect(_upgrade(BuildingType.coralMine).execute(s.game, s.player)
        .isSuccess, isTrue);
    expect(s.player.resources[ResourceType.coral]!.amount, greaterThan(0));
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/resource/resource.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/tech/tech_branch.dart';
import 'package:abyss/domain/tech/tech_branch_state.dart';
import 'package:abyss/domain/action/research_tech_action.dart';

({Game game, Player player}) makeScenario({
  int labLevel = 1,
  int ore = 500,
  int energy = 500,
  bool unlocked = true,
  int researchLevel = 0,
}) {
  final player = Player(
    id: 'test',
    name: 'Test',
    resources: {
      ResourceType.ore: Resource(type: ResourceType.ore, amount: ore),
      ResourceType.energy: Resource(type: ResourceType.energy, amount: energy),
      ResourceType.coral: Resource(type: ResourceType.coral, amount: 500),
      ResourceType.algae: Resource(type: ResourceType.algae, amount: 500),
      ResourceType.pearl: Resource(type: ResourceType.pearl, amount: 50),
    },
    buildings: {
      BuildingType.laboratory: Building(
        type: BuildingType.laboratory,
        level: labLevel,
      ),
    },
    techBranches: {
      TechBranch.military: TechBranchState(
        branch: TechBranch.military,
        unlocked: unlocked,
        researchLevel: researchLevel,
      ),
      TechBranch.resources: TechBranchState(branch: TechBranch.resources),
      TechBranch.explorer: TechBranchState(branch: TechBranch.explorer),
    },
  );
  final game =
      Game(humanPlayerId: player.id, players: {player.id: player});
  return (game: game, player: player);
}

void main() {
  late ResearchTechAction action;

  setUp(() {
    action = ResearchTechAction(branch: TechBranch.military);
  });

  group('validate', () {
    test('success: branch unlocked, lab level OK, resources OK', () {
      final s = makeScenario();
      expect(action.validate(s.game, s.player).isSuccess, isTrue);
    });

    test('branch locked returns failure', () {
      final s = makeScenario(unlocked: false);
      final result = action.validate(s.game, s.player);
      expect(result.isSuccess, isFalse);
    });

    test('max level reached returns failure', () {
      final s = makeScenario(researchLevel: 5, labLevel: 5);
      final result = action.validate(s.game, s.player);
      expect(result.isSuccess, isFalse);
    });

    test('lab level too low returns failure', () {
      final s = makeScenario(researchLevel: 1, labLevel: 1);
      final result = action.validate(s.game, s.player);
      expect(result.isSuccess, isFalse);
    });

    test('insufficient resources returns failure', () {
      final s = makeScenario(ore: 0, energy: 0);
      final result = action.validate(s.game, s.player);
      expect(result.isSuccess, isFalse);
    });
  });

  group('execute', () {
    test('success: resources deducted, researchLevel incremented', () {
      final s = makeScenario();
      final result = action.execute(s.game, s.player);
      expect(result.isSuccess, isTrue);
      // military level 1 costs ore: 40, energy: 25
      expect(s.player.resources[ResourceType.ore]!.amount, 460);
      expect(s.player.resources[ResourceType.energy]!.amount, 475);
      expect(s.player.techBranches[TechBranch.military]!.researchLevel, 1);
    });

    test('failure: game state unchanged', () {
      final s = makeScenario(ore: 0, energy: 0);
      final result = action.execute(s.game, s.player);
      expect(result.isSuccess, isFalse);
      expect(s.player.resources[ResourceType.ore]!.amount, 0);
      expect(s.player.resources[ResourceType.energy]!.amount, 0);
      expect(s.player.techBranches[TechBranch.military]!.researchLevel, 0);
    });
  });
}

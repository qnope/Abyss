import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/building.dart';
import 'package:abyss/domain/building_type.dart';
import 'package:abyss/domain/game.dart';
import 'package:abyss/domain/player.dart';
import 'package:abyss/domain/resource.dart';
import 'package:abyss/domain/resource_type.dart';
import 'package:abyss/domain/tech_branch.dart';
import 'package:abyss/domain/tech_branch_state.dart';
import 'package:abyss/domain/research_tech_action.dart';

Game makeGame({
  int labLevel = 1,
  int ore = 500,
  int energy = 500,
  bool unlocked = true,
  int researchLevel = 0,
}) {
  return Game(
    player: Player(name: 'Test'),
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
}

void main() {
  late ResearchTechAction action;

  setUp(() {
    action = ResearchTechAction(branch: TechBranch.military);
  });

  group('validate', () {
    test('success: branch unlocked, lab level OK, resources OK', () {
      final game = makeGame();
      expect(action.validate(game).isSuccess, isTrue);
    });

    test('branch locked returns failure', () {
      final game = makeGame(unlocked: false);
      final result = action.validate(game);
      expect(result.isSuccess, isFalse);
    });

    test('max level reached returns failure', () {
      final game = makeGame(researchLevel: 5, labLevel: 5);
      final result = action.validate(game);
      expect(result.isSuccess, isFalse);
    });

    test('lab level too low returns failure', () {
      final game = makeGame(researchLevel: 1, labLevel: 1);
      final result = action.validate(game);
      expect(result.isSuccess, isFalse);
    });

    test('insufficient resources returns failure', () {
      final game = makeGame(ore: 0, energy: 0);
      final result = action.validate(game);
      expect(result.isSuccess, isFalse);
    });
  });

  group('execute', () {
    test('success: resources deducted, researchLevel incremented', () {
      final game = makeGame();
      final result = action.execute(game);
      expect(result.isSuccess, isTrue);
      // military level 1 costs ore: 40, energy: 25
      expect(game.resources[ResourceType.ore]!.amount, 460);
      expect(game.resources[ResourceType.energy]!.amount, 475);
      expect(game.techBranches[TechBranch.military]!.researchLevel, 1);
    });

    test('failure: game state unchanged', () {
      final game = makeGame(ore: 0, energy: 0);
      final result = action.execute(game);
      expect(result.isSuccess, isFalse);
      expect(game.resources[ResourceType.ore]!.amount, 0);
      expect(game.resources[ResourceType.energy]!.amount, 0);
      expect(game.techBranches[TechBranch.military]!.researchLevel, 0);
    });
  });
}

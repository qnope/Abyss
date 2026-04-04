import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/building.dart';
import 'package:abyss/domain/building_type.dart';
import 'package:abyss/domain/game.dart';
import 'package:abyss/domain/player.dart';
import 'package:abyss/domain/resource.dart';
import 'package:abyss/domain/resource_type.dart';
import 'package:abyss/domain/tech_branch.dart';
import 'package:abyss/domain/tech_branch_state.dart';
import 'package:abyss/domain/unlock_branch_action.dart';

Game makeGame({
  int labLevel = 1,
  int ore = 100,
  int energy = 100,
  int coral = 100,
  int algae = 100,
  bool militaryUnlocked = false,
}) {
  return Game(
    player: Player(name: 'Test'),
    resources: {
      ResourceType.ore: Resource(type: ResourceType.ore, amount: ore),
      ResourceType.energy: Resource(type: ResourceType.energy, amount: energy),
      ResourceType.coral: Resource(type: ResourceType.coral, amount: coral),
      ResourceType.algae: Resource(type: ResourceType.algae, amount: algae),
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
        unlocked: militaryUnlocked,
      ),
      TechBranch.resources: TechBranchState(branch: TechBranch.resources),
      TechBranch.explorer: TechBranchState(branch: TechBranch.explorer),
    },
  );
}

void main() {
  late UnlockBranchAction action;

  setUp(() {
    action = UnlockBranchAction(branch: TechBranch.military);
  });

  group('validate', () {
    test('success case', () {
      final game = makeGame();
      expect(action.validate(game).isSuccess, isTrue);
    });

    test('lab not built returns failure', () {
      final game = makeGame(labLevel: 0);
      final result = action.validate(game);
      expect(result.isSuccess, isFalse);
    });

    test('branch already unlocked returns failure', () {
      final game = makeGame(militaryUnlocked: true);
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
    test('success: resources deducted and branch unlocked', () {
      final game = makeGame();
      final result = action.execute(game);
      expect(result.isSuccess, isTrue);
      expect(game.resources[ResourceType.ore]!.amount, 70);
      expect(game.resources[ResourceType.energy]!.amount, 80);
      expect(game.techBranches[TechBranch.military]!.unlocked, isTrue);
    });

    test('failure: game state unchanged', () {
      final game = makeGame(ore: 0, energy: 0);
      final result = action.execute(game);
      expect(result.isSuccess, isFalse);
      expect(game.resources[ResourceType.ore]!.amount, 0);
      expect(game.resources[ResourceType.energy]!.amount, 0);
      expect(game.techBranches[TechBranch.military]!.unlocked, isFalse);
    });
  });
}

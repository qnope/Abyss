import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/resource/resource.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/tech/tech_branch.dart';
import 'package:abyss/domain/tech/tech_branch_state.dart';
import 'package:abyss/domain/action/unlock_branch_action.dart';

({Game game, Player player}) makeScenario({
  int labLevel = 1,
  int ore = 100,
  int energy = 100,
  bool militaryUnlocked = false,
}) {
  final player = Player(
    id: 'test',
    name: 'Test',
    resources: {
      ResourceType.ore: Resource(type: ResourceType.ore, amount: ore),
      ResourceType.energy: Resource(type: ResourceType.energy, amount: energy),
      ResourceType.coral: Resource(type: ResourceType.coral, amount: 100),
      ResourceType.algae: Resource(type: ResourceType.algae, amount: 100),
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
  final game =
      Game(humanPlayerId: player.id, players: {player.id: player});
  return (game: game, player: player);
}

void main() {
  late UnlockBranchAction action;

  setUp(() {
    action = UnlockBranchAction(branch: TechBranch.military);
  });

  group('validate', () {
    test('success case', () {
      final s = makeScenario();
      expect(action.validate(s.game, s.player).isSuccess, isTrue);
    });

    test('lab not built returns failure', () {
      final s = makeScenario(labLevel: 0);
      final result = action.validate(s.game, s.player);
      expect(result.isSuccess, isFalse);
    });

    test('branch already unlocked returns failure', () {
      final s = makeScenario(militaryUnlocked: true);
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
    test('success: resources deducted and branch unlocked', () {
      final s = makeScenario();
      final result = action.execute(s.game, s.player);
      expect(result.isSuccess, isTrue);
      expect(s.player.resources[ResourceType.ore]!.amount, 70);
      expect(s.player.resources[ResourceType.energy]!.amount, 80);
      expect(s.player.techBranches[TechBranch.military]!.unlocked, isTrue);
    });

    test('failure: game state unchanged', () {
      final s = makeScenario(ore: 0, energy: 0);
      final result = action.execute(s.game, s.player);
      expect(result.isSuccess, isFalse);
      expect(s.player.resources[ResourceType.ore]!.amount, 0);
      expect(s.player.resources[ResourceType.energy]!.amount, 0);
      expect(s.player.techBranches[TechBranch.military]!.unlocked, isFalse);
    });
  });
}

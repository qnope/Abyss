import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/resource/resource.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/tech/tech_branch.dart';
import 'package:abyss/domain/tech/tech_option.dart';
import 'package:abyss/presentation/screens/game/game_screen_tech_actions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Game gameWith({required int labLevel, int stock = 500}) {
    final player = Player(
      name: 'Nemo',
      resources: {
        for (final type in ResourceType.values)
          type: Resource(type: type, amount: stock, maxStorage: 1000),
      },
      buildings: {
        BuildingType.laboratory:
            Building(type: BuildingType.laboratory, level: labLevel),
      },
    );
    return Game.singlePlayer(player);
  }

  group('unlockBranch', () {
    test('unlocks the branch and notifies the change', () {
      final game = gameWith(labLevel: 1);
      var changes = 0;
      unlockBranch(game, TechBranch.military, () => changes++);

      expect(game.humanPlayer.techBranches[TechBranch.military]!.unlocked,
          isTrue);
      expect(changes, 1);
    });

    test('does not notify when the laboratory is missing', () {
      final game = gameWith(labLevel: 0);
      var changes = 0;
      unlockBranch(game, TechBranch.military, () => changes++);

      expect(game.humanPlayer.techBranches[TechBranch.military]!.unlocked,
          isFalse);
      expect(changes, 0);
    });
  });

  group('researchTech', () {
    test('researches the next level of an unlocked branch', () {
      final game = gameWith(labLevel: 1);
      game.humanPlayer.techBranches[TechBranch.explorer]!.unlocked = true;
      var changes = 0;
      researchTech(
          game, TechBranch.explorer, TechOption.a, () => changes++);

      expect(
          game.humanPlayer.techBranches[TechBranch.explorer]!.researchLevel,
          1);
      expect(changes, 1);
    });

    test('records the option taken at a choice node', () {
      final game = gameWith(labLevel: 2);
      final state = game.humanPlayer.techBranches[TechBranch.explorer]!
        ..unlocked = true
        ..researchLevel = 1;
      var changes = 0;
      researchTech(
          game, TechBranch.explorer, TechOption.b, () => changes++);

      expect(state.researchLevel, 2);
      expect(state.optionAt(2), TechOption.b);
      expect(changes, 1);
    });

    test('does not notify when the branch is locked', () {
      final game = gameWith(labLevel: 1);
      var changes = 0;
      researchTech(
          game, TechBranch.explorer, TechOption.a, () => changes++);

      expect(
          game.humanPlayer.techBranches[TechBranch.explorer]!.researchLevel,
          0);
      expect(changes, 0);
    });
  });
}

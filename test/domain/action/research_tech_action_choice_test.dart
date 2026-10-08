import 'package:abyss/domain/action/research_tech_action.dart';
import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/resource/resource.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/tech/tech_branch.dart';
import 'package:abyss/domain/tech/tech_branch_state.dart';
import 'package:abyss/domain/tech/tech_option.dart';
import 'package:abyss/domain/tech/tech_perk.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/tech_helpers.dart';

({Game game, Player player}) _scenario(List<TechBranchState> states) {
  final player = Player(
    id: 'test',
    name: 'Test',
    resources: {
      for (final t in ResourceType.values)
        t: Resource(type: t, amount: 900, maxStorage: 1000),
    },
    buildings: {
      BuildingType.laboratory:
          Building(type: BuildingType.laboratory, level: 5),
    },
    techBranches: techBranchesWith(states),
  );
  return (
    game: Game(humanPlayerId: player.id, players: {player.id: player}),
    player: player,
  );
}

TechBranchState _military(Player p) => p.techBranches[TechBranch.military]!;

void main() {
  const military = TechBranch.military;

  test('researching a choice node records the option taken', () {
    final s = _scenario([researchedBranch(military, 1)]);
    final result = ResearchTechAction(branch: military, option: TechOption.b)
        .execute(s.game, s.player);

    expect(result.isSuccess, isTrue);
    expect(_military(s.player).researchLevel, 2);
    expect(_military(s.player).optionAt(2), TechOption.b);
    expect(_military(s.player).perks, {TechPerk.nacreShell});
  });

  test('the option defaults to A', () {
    final s = _scenario([researchedBranch(military, 3, options: [TechOption.b])]);
    ResearchTechAction(branch: military).execute(s.game, s.player);

    expect(_military(s.player).choices,
        [TechOption.b.index, TechOption.a.index]);
  });

  test('a tier node ignores the option', () {
    final s = _scenario([researchedBranch(military, 2, options: [TechOption.a])]);
    ResearchTechAction(branch: military, option: TechOption.b)
        .execute(s.game, s.player);

    expect(_military(s.player).researchLevel, 3);
    expect(_military(s.player).choices, [TechOption.a.index]);
  });

  test('a failed research records no choice', () {
    final s = _scenario([researchedBranch(military, 1)]);
    s.player.buildings[BuildingType.laboratory]!.level = 1;
    final result = ResearchTechAction(branch: military, option: TechOption.b)
        .execute(s.game, s.player);

    expect(result.isSuccess, isFalse);
    expect(_military(s.player).choices, isEmpty);
  });

  test('the cost grows with every other branch opened', () {
    final s = _scenario([
      researchedBranch(military, 0),
      researchedBranch(TechBranch.explorer, 0),
    ]);
    ResearchTechAction(branch: military).execute(s.game, s.player);

    // Level 1 costs ore 80 / energy 50, x1.5 with two branches opened.
    expect(s.player.resources[ResourceType.ore]!.amount, 900 - 120);
    expect(s.player.resources[ResourceType.energy]!.amount, 900 - 75);
  });
}

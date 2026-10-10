import 'dart:math';

import 'package:abyss/domain/action/action_executor.dart';
import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/faction/faction_turn.dart';
import 'package:abyss/domain/faction/faction_war.dart';
import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/kernel_war_helper.dart';

KernelWar _scene({int kernelLevel = 3}) {
  final war = KernelWar(kernelLevel: kernelLevel);
  while (!FactionWar.isDue(war.game.turn, war.game.factions[0].personality)) {
    war.game.turn++;
  }
  war.attacker.addRevealedCell(3, war.at);
  return war;
}

void _play(KernelWar war) => FactionWar.play(
  FactionTurn(
    game: war.game,
    player: war.attacker,
    executor: ActionExecutor(),
    seeds: Random(2),
  ),
  war.game.factions[0].personality,
);

void main() {
  test('a faction lays siege to a weakly held kernel it has seen', () {
    final war = _scene()..arm()..garrison(smallGarrison);

    _play(war);

    expect(war.kernelOf(war.owner), 2);
    expect(
      war.owner.historyEntries.whereType<BaseAssaultEntry>(),
      hasLength(1),
    );
  });

  test('it takes the kernel when the last level falls', () {
    final war = _scene(kernelLevel: 1)..arm()..garrison(smallGarrison);

    _play(war);

    expect(war.holder, war.attacker.id);
  });

  test('it leaves a kernel whose defence it would not beat', () {
    final war = _scene(kernelLevel: 8)
      ..arm({UnitType.harpoonist: 6})
      ..garrison(fortress);

    _play(war);

    expect(war.kernelOf(war.owner), 8);
    expect(war.attacker.historyEntries.whereType<BaseAssaultEntry>(), isEmpty);
  });

  test('it ignores a kernel its fog has not shown', () {
    final war = _scene()..arm()..garrison(smallGarrison);
    war.attacker.revealedCellsPerLevel[3] = [];

    _play(war);

    expect(war.kernelOf(war.owner), 3);
  });

  test('a kernel of the human falls at once, without announcement', () {
    final war = _scene()..arm();
    final map = war.game.levels[3]!;
    map.setCell(
      war.at.x,
      war.at.y,
      map.cellAt(war.at.x, war.at.y).copyWith(collectedBy: war.human.id),
    );
    war.human.buildings[BuildingType.volcanicKernel] = Building(
      type: BuildingType.volcanicKernel,
      level: 1,
    );

    _play(war);

    expect(war.holder, war.attacker.id);
    final entry = war.human.historyEntries.whereType<BaseAssaultEntry>().single;
    expect(entry.defending, isTrue);
    expect(entry.postName, 'volcanicKernel');
  });
}

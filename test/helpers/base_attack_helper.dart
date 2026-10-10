import 'dart:math';

import 'package:abyss/domain/action/attack_base_action.dart';
import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/replay/seeded_random.dart';
import 'package:abyss/domain/unit/unit_type.dart';

import 'two_player_game.dart';

/// A two-player game at turn 12 where the human has seen the rival's
/// base and both have a headquarters at level 5.
TwoPlayerGame assaultGame({int turn = 12, bool revealed = true}) {
  final two = TwoPlayerGame.create(rivalId: 'rival-1');
  two.game.turn = turn;
  for (final p in [two.human, two.rival]) {
    setLevel(p, BuildingType.headquarters, 5);
  }
  if (revealed) {
    two.human.addRevealedCell(
      1,
      GridPosition(x: two.rival.baseX, y: two.rival.baseY),
    );
  }
  return two;
}

void setLevel(Player player, BuildingType type, int level) {
  player.buildings[type] = Building(type: type, level: level);
}

/// Puts exactly [units] on the base level of [player].
void station(Player player, Map<UnitType, int> units) {
  for (final unit in player.unitsOnLevel(1).values) {
    unit.count = 0;
  }
  units.forEach((t, n) => player.unitsOnLevel(1)[t]!.count = n);
}

int standing(Player player, UnitType type) =>
    player.unitsOnLevel(1)[type]!.count;

AttackBaseAction strike(
  TwoPlayerGame two,
  Map<UnitType, int> army, {
  int seed = 1,
}) => AttackBaseAction(
  targetPlayerId: two.rival.id,
  selectedUnits: army,
  random: SeededRandom(seed),
);

/// An army that beats a bare base, and a defence nobody beats.
const Map<UnitType, int> horde = {UnitType.harpoonist: 40};
const Map<UnitType, int> wall = {
  UnitType.guardian: 60,
  UnitType.harpoonist: 60,
};
Random dice() => Random(7);

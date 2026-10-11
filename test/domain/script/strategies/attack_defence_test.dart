import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/fight/army_planner.dart';
import 'package:abyss/domain/raid/announced_attack.dart';
import 'package:abyss/domain/replay/seeded_random.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/script/script_turn.dart';
import 'package:abyss/domain/script/strategies/battle_moves.dart';
import 'package:abyss/domain/script/strategies/conquest_strategy.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/announce_attack_helper.dart';
import '../../../helpers/base_attack_helper.dart';
import '../../../helpers/two_player_game.dart';

const ArmyPlanner _planner = ArmyPlanner();

TwoPlayerGame _attacked({required bool rich}) {
  final two = announceGame();
  setLevel(two.human, BuildingType.barracks, 5);
  station(two.human, {UnitType.harpoonist: 2});
  for (final r in ResourceType.values) {
    two.human.resources[r]!.amount = rich ? 50000 : 0;
  }
  two.human.raidState.attacks.add(
    AnnouncedAttack(
      attackerId: two.rival.id,
      units: const {UnitType.harpoonist: 12},
      arrivalTurn: two.game.turn + 2,
      seed: 1,
    ),
  );
  return two;
}

ScriptTurn _turn(TwoPlayerGame two) =>
    ScriptTurn(game: two.game, random: SeededRandom(1), log: []);

void main() {
  test('a player recruits to hold a base attack that is announced', () {
    final two = _attacked(rich: true);
    final before = standing(two.human, UnitType.harpoonist);

    _turn(two).defendAttacks(_planner);

    expect(standing(two.human, UnitType.harpoonist), greaterThan(before));
  });

  test('without an announced attack it recruits nothing', () {
    final two = _attacked(rich: true);
    two.human.raidState.attacks.clear();

    _turn(two).defendAttacks(_planner);

    expect(standing(two.human, UnitType.harpoonist), 2);
  });

  test('a player with nothing to spend does what it can', () {
    final two = _attacked(rich: false);

    expect(_turn(two).defendAttacks(_planner), isFalse);
    expect(standing(two.human, UnitType.harpoonist), 2);
  });

  test('the careful strategy holds the attacks it is warned of', () {
    final two = _attacked(rich: true);

    const ConquestStrategy().playTurn(_turn(two));

    expect(standing(two.human, UnitType.harpoonist), greaterThan(2));
  });
}

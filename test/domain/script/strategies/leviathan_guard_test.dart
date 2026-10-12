import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/faction/faction_attack_report.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_lair.dart';
import 'package:abyss/domain/raid/announced_attack.dart';
import 'package:abyss/domain/replay/seeded_random.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/script/script_turn.dart';
import 'package:abyss/domain/script/strategies/conquest_strategy.dart';
import 'package:abyss/domain/script/strategies/leviathan_guard_moves.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/post_attack_helper.dart';
import '../../leviathan/leviathan_scene.dart';

const Map<UnitType, int> home = {
  UnitType.guardian: 60,
  UnitType.domeBreaker: 60,
  UnitType.harpoonist: 60,
};

ScriptTurn turnOf(PostWar war) =>
    ScriptTurn(game: war.game, random: SeededRandom(5), log: []);

int unitsOn(PostWar war, int level) => UnitType.values.fold(
  0,
  (int sum, UnitType t) => sum + war.count(war.human, level, t),
);

/// The scene at the turn the guardians strike, [units] waiting at home.
PostWar warned([Map<UnitType, int> units = home]) {
  final war = leviathanScene();
  war.put(war.human, 1, units);
  war.playUntil(war.strikeTurn);
  return war;
}

void main() {
  test('it sends down part of the home army and holds the Faille', () {
    final war = warned();
    turnOf(war).guardFaille();

    expect(unitsOn(war, 2), greaterThan(0));
    expect(unitsOn(war, 1), greaterThan(0));
    final report = war.endTurn().report!;
    expect(report.outcome, AttackOutcome.repelled);
    expect(war.post.capturedBy, war.human.id);
  });

  test('it does nothing before the turn they strike', () {
    final war = leviathanScene();
    war.put(war.human, 1, home);
    turnOf(war).guardFaille();

    expect(unitsOn(war, 2), 0);
  });

  test('units already below that hold keep the home army home', () {
    final war = warned();
    war.put(war.human, 2, wall);
    turnOf(war).guardFaille();

    expect(unitsOn(war, 1), 180);
  });

  test('with no army at home it recruits the guard it sends down', () {
    final war = warned(const {});
    war.human.buildings[BuildingType.barracks] = Building(
      type: BuildingType.barracks,
      level: 10,
    );
    for (final r in ResourceType.values) {
      war.human.resources[r]!.amount = 200000;
    }
    turnOf(war).guardFaille();

    expect(unitsOn(war, 2), greaterThan(0));
    expect(war.endTurn().report!.outcome, AttackOutcome.repelled);
  });

  test('under a raid it sends down only what the base can spare', () {
    final war = warned();
    war.human.raidState.announce(
      const MonsterLair(difficulty: MonsterDifficulty.easy, unitCount: 4),
      war.game.turn + 1,
    );
    turnOf(war).guardFaille();

    expect(unitsOn(war, 2), greaterThan(0));
    expect(war.endTurn().report!.outcome, AttackOutcome.repelled);
  });

  test('under a raid the base needs, only fresh recruits go down', () {
    final war = warned();
    war.human.raidState.announce(
      const MonsterLair(difficulty: MonsterDifficulty.hard, unitCount: 300),
      war.game.turn + 1,
    );
    turnOf(war).guardFaille();

    expect(unitsOn(war, 1), 180);
  });

  test('under a faction attack the base needs, the army stays home', () {
    final war = warned();
    war.human.raidState.attacks.add(
      AnnouncedAttack(
        attackerId: war.attacker.id,
        units: const {UnitType.harpoonist: 400},
        arrivalTurn: war.game.turn + 1,
        seed: 1,
      ),
    );
    turnOf(war).guardFaille();

    expect(unitsOn(war, 1), 180);
  });

  test('a hopeless guard stays home', () {
    final war = warned(const {UnitType.harpoonist: 2});
    turnOf(war).guardFaille();

    expect(unitsOn(war, 2), 0);
  });

  test('without its Module the Faille is left to its fate', () {
    final war = warned();
    war.human.buildings[BuildingType.descentModule] = Building(
      type: BuildingType.descentModule,
    );
    turnOf(war).guardFaille();

    expect(unitsOn(war, 2), 0);
  });

  test('the careful bot holds the Faille it is warned about', () {
    final war = warned();
    const ConquestStrategy().playTurn(turnOf(war));

    expect(war.endTurn().report!.outcome, AttackOutcome.repelled);
    expect(war.post.capturedBy, war.human.id);
  });
}

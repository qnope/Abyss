import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_family.dart';
import 'package:abyss/domain/map/monster_lair.dart';
import 'package:abyss/domain/objective/guide/guide_message.dart';
import 'package:abyss/domain/objective/guide/guide_target.dart';
import 'package:abyss/domain/objective/objective_id.dart';
import 'package:abyss/domain/raid/raid_defence_advisor.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/guide_helpers.dart';
import '../../../helpers/objective_helpers.dart';

const _wave = MonsterLair(
  difficulty: MonsterDifficulty.easy,
  family: MonsterFamily.swarm,
  unitCount: 22,
  secondFamily: MonsterFamily.armoured,
  secondCount: 6,
);

/// On the first raid objective at turn 10, the [_wave] announced for the
/// end of turn [arrival], with [harpoonists] on the base.
Game _raidGame({int harpoonists = 0, int arrival = 12}) {
  final game = guideGame(ObjectiveId.firstRaid)..turn = 10;
  game.humanPlayer.raidState.announce(_wave, arrival);
  setUnits(game.humanPlayer, UnitType.harpoonist, harpoonists);
  return game;
}

int _needed(Game game) =>
    RaidDefenceAdvisor.harpoonistsFor(game.humanPlayer, _wave)!;

void main() {
  test('names the harpoonists to have against the first raid', () {
    final game = _raidGame(harpoonists: 3);
    final int needed = _needed(game);

    final advice = adviceOf(game)!;

    expect(
      advice.message,
      GuideRaidAlert(
        12,
        28,
        needed: needed,
        missing: needed - 3,
        canRecruit: true,
      ),
    );
    expect(advice.target, const GuideTarget.unit(UnitType.harpoonist));
  });

  test('a base strong enough waits for the raid', () {
    final game = _raidGame();
    setUnits(game.humanPlayer, UnitType.harpoonist, _needed(game));

    final advice = adviceOf(game)!;

    expect(advice.message, GuideRaidAlert(12, 28, needed: _needed(game)));
    expect(advice.target, const GuideTarget.endTurn());
  });

  test('harpoonists already recruited this turn: the rest next turn', () {
    final game = _raidGame();
    game.humanPlayer.recruitedUnitTypes.add(UnitType.harpoonist);

    final advice = adviceOf(game)!;

    expect(
      advice.message,
      GuideRaidAlert(12, 28, needed: _needed(game), missing: _needed(game)),
    );
    expect(advice.target, const GuideTarget.endTurn());
  });

  test('harpoonists already recruited on the last turn: hold on', () {
    final game = _raidGame(arrival: 10);
    game.humanPlayer.recruitedUnitTypes.add(UnitType.harpoonist);

    final advice = adviceOf(game)!;

    expect(
      advice.message,
      GuideRaidAlert(
        10,
        28,
        needed: _needed(game),
        missing: _needed(game),
        lastTurn: true,
      ),
    );
    expect(advice.target, const GuideTarget.endTurn());
  });

  test('a wave out of reach asks for as many harpoonists as possible', () {
    final game = guideGame(ObjectiveId.firstRaid)..turn = 10;
    game.humanPlayer.raidState.announce(
      const MonsterLair(difficulty: MonsterDifficulty.hard, unitCount: 400),
      12,
    );

    final advice = adviceOf(game)!;

    expect(advice.message, const GuideRaidAlert(12, 400));
    expect(advice.target, const GuideTarget.unit(UnitType.harpoonist));
  });
}

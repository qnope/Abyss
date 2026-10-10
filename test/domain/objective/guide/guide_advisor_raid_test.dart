import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_family.dart';
import 'package:abyss/domain/map/monster_lair.dart';
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
      advice.text,
      'Le raid arrive au tour 12 avec 28 monstres. Aie au moins $needed '
      'Harponneurs au niveau 1 : il t\'en manque ${needed - 3}. '
      'Recrute-les dans l\'onglet Armée.',
    );
    expect(advice.target, const GuideTarget.unit(UnitType.harpoonist));
  });

  test('a base strong enough waits for the raid', () {
    final game = _raidGame();
    setUnits(game.humanPlayer, UnitType.harpoonist, _needed(game));

    final advice = adviceOf(game)!;

    expect(advice.text, startsWith('Le raid arrive au tour 12 avec 28'));
    expect(advice.text, contains('termine le tour'));
    expect(advice.text, isNot(contains('manque')));
    expect(advice.target, const GuideTarget.endTurn());
  });

  test('harpoonists already recruited this turn: the rest next turn', () {
    final game = _raidGame();
    game.humanPlayer.recruitedUnitTypes.add(UnitType.harpoonist);

    final advice = adviceOf(game)!;

    expect(advice.text, contains('manque'));
    expect(advice.text, contains('au prochain tour'));
    expect(advice.target, const GuideTarget.endTurn());
  });

  test('harpoonists already recruited on the last turn: hold on', () {
    final game = _raidGame(arrival: 10);
    game.humanPlayer.recruitedUnitTypes.add(UnitType.harpoonist);

    final advice = adviceOf(game)!;

    expect(advice.text, contains('manque'));
    expect(advice.text, isNot(contains('prochain')));
    expect(advice.target, const GuideTarget.endTurn());
  });

  test('a wave out of reach asks for as many harpoonists as possible', () {
    final game = guideGame(ObjectiveId.firstRaid)..turn = 10;
    game.humanPlayer.raidState.announce(
      const MonsterLair(difficulty: MonsterDifficulty.hard, unitCount: 400),
      12,
    );

    final advice = adviceOf(game)!;

    expect(advice.text, contains('400 monstres'));
    expect(advice.text, contains('autant de Harponneurs'));
    expect(advice.target, const GuideTarget.unit(UnitType.harpoonist));
  });
}

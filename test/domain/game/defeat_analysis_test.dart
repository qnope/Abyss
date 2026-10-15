import 'package:abyss/domain/game/defeat_analysis.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_family.dart';
import 'package:abyss/domain/map/monster_lair.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/transition_fight_fixtures.dart';

void main() {
  const wave = MonsterLair(
    difficulty: MonsterDifficulty.easy,
    family: MonsterFamily.swarm,
    unitCount: 30,
    secondFamily: MonsterFamily.hunter,
    secondCount: 10,
  );

  RaidEntry raid(
    int turn,
    Map<UnitType, int> defenders, {
    bool victory = false,
    bool surprise = false,
  }) => RaidEntry(
    turn: turn,
    victory: victory,
    wave: wave,
    fightResult: buildTestFight(playerWins: victory),
    loot: const {},
    pillaged: const {},
    defenders: defenders,
    survivorsIntact: const {},
    wounded: const {},
    dead: const {},
    rampartLevel: 0,
    surprise: surprise,
  );

  Game gameWith(List<HistoryEntry> history) => Game.singlePlayer(
    Player(name: 'Nemo', baseX: 1, baseY: 1, historyEntries: history),
  );

  test('lists the three raids lost in a row, oldest first', () {
    final analysis =
        DefeatAnalysis.of(
          gameWith([
            raid(5, const {}, victory: true),
            raid(13, const {}),
            raid(20, const {}, surprise: true),
            raid(29, const {}),
            raid(43, const {}),
          ]),
        )!;
    expect(analysis.raids.map((r) => r.turn), [13, 29, 43]);
    expect(analysis.raids.first.wave, wave);
  });

  test('without any defender, the advice is to raise an army', () {
    final analysis =
        DefeatAnalysis.of(
          gameWith([
            raid(13, const {}),
            raid(29, const {}),
            raid(43, const {}),
          ]),
        )!;
    expect(analysis.raids.map((r) => r.defenders), [0, 0, 0]);
    expect(analysis.advice, DefeatAdvice.raiseAnArmy);
  });

  test('with too few defenders, it tells how many Harpoonists it took', () {
    final analysis =
        DefeatAnalysis.of(
          gameWith([
            raid(13, const {}),
            raid(29, const {UnitType.scout: 2}),
            raid(43, const {UnitType.harpoonist: 1}),
          ]),
        )!;
    expect(analysis.raids.last.defenders, 1);
    expect(analysis.advice, DefeatAdvice.moreDefenders);
    expect(analysis.harpoonistsNeeded, greaterThan(1));
  });

  test('with enough bodies but the wrong units, it names the answers', () {
    final analysis =
        DefeatAnalysis.of(
          gameWith([
            raid(13, const {}),
            raid(29, const {}),
            raid(43, const {UnitType.scout: 500}),
          ]),
        )!;
    expect(analysis.advice, DefeatAdvice.counterTheFamilies);
  });

  test('without lost raids there is nothing to explain', () {
    expect(
      DefeatAnalysis.of(gameWith([raid(5, const {}, victory: true)])),
      isNull,
    );
  });
}

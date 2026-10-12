import 'package:abyss/domain/game/game_factory.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/transition_base_type.dart';
import 'package:abyss/domain/script/batch_runner.dart';
import 'package:abyss/domain/script/idle_script.dart';
import 'package:abyss/domain/script/script_library.dart';
import 'package:abyss/domain/script/script_milestones.dart';
import 'package:abyss/domain/script/script_runner.dart';
import 'package:abyss/domain/volcano/volcano_report.dart';
import 'package:abyss/domain/volcano/volcano_wave_factory.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/post_attack_helper.dart';
import '../../helpers/transition_fight_fixtures.dart';
import '../leviathan/leviathan_scene.dart';

void main() {
  test('notes the first turn a Faille is held, and only the first', () {
    final game = GameFactory.newSinglePlayer(playerName: 'p', mapSeed: 3);
    final milestones = ScriptMilestones()..observe(game, 4);
    expect(milestones.failleCaptured, isNull);

    final faille = game.levels[1]!.cells.firstWhere((c) =>
        c.content == CellContentType.transitionBase &&
        c.transitionBase!.type == TransitionBaseType.faille);
    faille.transitionBase!.capturedBy = game.humanPlayerId;
    milestones
      ..observe(game, 9)
      ..observe(game, 12);

    expect(milestones.failleCaptured, 9);
    expect(milestones.chemineeCaptured, isNull);
    expect(milestones.kernelCaptured, isNull);
  });

  test('the runner records every raid of the game', () {
    final report = ScriptRunner(maxTurns: 60).run(const IdleScript(), seed: 1);
    final raids = report.milestones.raids;

    expect(raids, hasLength(report.raidsLost + report.raidsRepelled));
    expect(raids.every((r) => !r.victory && r.monsters > 0), isTrue);
  });

  test('a batch tells how many games reached a milestone, and when', () async {
    final report = await BatchRunner(runner: ScriptRunner(maxTurns: 60))
        .run((_) => const IdleScript(), games: 2, firstSeed: 8);

    final fall = report.milestone((r) => r.isDefeat ? r.turnsPlayed : null);
    expect(fall.games, 2);
    expect(fall.averageTurn, report.earliestDefeat);
    expect(report.milestone((r) => r.milestones.kernelCaptured).games, 0);
  });

  test('notes when the guardians struck the Faille back, and the outcome', () {
    final kept = leviathanScene();
    kept.put(kept.human, 2, wall);
    final lost = leviathanScene();
    final milestones = ScriptMilestones()..observeLeviathan(null);
    expect(milestones.leviathanStruck, isNull);
    expect(milestones.leviathanHeld, isNull);

    kept.playUntil(kept.strikeTurn);
    milestones.observeLeviathan(kept.endTurn().report);
    expect(milestones.leviathanStruck, kept.strikeTurn);
    expect(milestones.leviathanHeld, isTrue);
    lost.playUntil(lost.strikeTurn);
    milestones.observeLeviathan(lost.endTurn().report);
    expect(milestones.leviathanHeld, isFalse);
    expect(milestones.toJson()['leviathanHeld'], isFalse);
  });

  test('the careful bot holds the Faille the guardians strike back', () {
    final report = ScriptRunner(maxTurns: 45).run(
      ScriptLibrary.byName('conquest'),
      seed: 1,
    );
    final milestones = report.milestones;

    // 3 turns after the capture at the earliest: later when the Module de
    // descente works after it.
    expect(
      milestones.leviathanStruck,
      greaterThanOrEqualTo(milestones.failleCaptured! + 3),
    );
    expect(milestones.leviathanHeld, isTrue);
  });

  test('records every kraken wave fought on the kernel', () {
    final wave = VolcanoWaveFactory.fromKernelLevel(2);
    VolcanoReport report(bool victory) => VolcanoReport(
      turn: 70,
      victory: victory,
      wave: wave,
      fight: buildTestFight(playerWins: victory),
      kernelLevel: 2,
      defenders: const {},
      survivorsIntact: const {},
      wounded: const {},
      dead: const {},
    );
    final milestones = ScriptMilestones()
      ..observeWave(null)
      ..observeWave(report(true))
      ..observeWave(report(false));

    expect(milestones.waves.map((w) => w.victory), [true, false]);
    expect(milestones.waves.first.monsters, wave.totalCount);
    expect(milestones.waves.first.monsterLevel, wave.level);
    expect(milestones.toJson()['waves'], hasLength(2));
  });
}

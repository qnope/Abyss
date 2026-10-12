import 'package:abyss/domain/game/game_statistics.dart';
import 'package:abyss/domain/game/game_status.dart';
import 'package:abyss/domain/script/batch_report.dart';
import 'package:abyss/domain/script/batch_summary.dart';
import 'package:abyss/domain/script/script_milestones.dart';
import 'package:abyss/domain/script/script_run_report.dart';
import 'package:flutter_test/flutter_test.dart';

ScriptRaid _wave(bool victory) =>
    ScriptRaid(turn: 80, monsters: 6, monsterLevel: 4, victory: victory);

ScriptRunReport _run(GameStatus status, ScriptMilestones milestones) =>
    ScriptRunReport(
      scriptName: 'conquest',
      seed: 1,
      status: status,
      statistics: const GameStatistics(
        turnsPlayed: 90,
        monstersDefeated: 0,
        basesCaptured: 0,
        totalResourcesCollected: 0,
        raidsLost: 1,
        raidsRepelled: 3,
      ),
      turnsPlayed: 90,
      totalNoise: 100,
      buildings: const {},
      baseUnits: const {},
      resources: const {},
      log: const [],
      milestones: milestones,
    );

void main() {
  test('sums up a batch, the Léviathan and the kraken waves included', () {
    final held =
        ScriptMilestones()
          ..failleCaptured = 30
          ..leviathanStruck = 33
          ..leviathanHeld = true;
    held.waves.addAll([_wave(true), _wave(false)]);
    final lost =
        ScriptMilestones()
          ..failleCaptured = 40
          ..leviathanStruck = 43
          ..leviathanHeld = false;
    final lines = BatchSummary.linesOf(
      'conquest',
      BatchReport([
        _run(GameStatus.victory, held),
        _run(GameStatus.defeat, lost),
      ]),
    );

    expect(lines, [
      'Stratégie : conquest, 2 parties',
      'Survie : 50 % (1 défaites, 1 victoires)',
      'Tours joués en moyenne : 90.0',
      'Raids repoussés / perdus en moyenne : 3.0 / 1.0',
      'Bruit total moyen : 100.0',
      'Première défaite : tour 90',
      'Faille prise : 2/2 parties, tour 35.0 en moyenne',
      'Victoire : 1/2 parties, tour 90.0 en moyenne',
      'Léviathan : 2/2 parties, tour 38.0 en moyenne',
      'Module perdu au Léviathan : 1/2 parties, tour 43.0 en moyenne',
      'Vagues du Noyau : 2 combattues, 1 perdues',
    ]);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/game/game_statistics.dart';
import 'package:abyss/domain/game/game_status.dart';
import 'package:abyss/domain/script/batch_report.dart';
import 'package:abyss/domain/script/script_milestones.dart';
import 'package:abyss/domain/script/script_run_report.dart';

ScriptRunReport _run({
  GameStatus status = GameStatus.playing,
  int turns = 10,
  int noise = 0,
  int raidsLost = 0,
  int raidsRepelled = 0,
  int? faille,
}) {
  return ScriptRunReport(
    scriptName: 'test',
    seed: 1,
    status: status,
    statistics: GameStatistics(
      turnsPlayed: turns,
      monstersDefeated: 0,
      basesCaptured: 0,
      totalResourcesCollected: 0,
      raidsLost: raidsLost,
      raidsRepelled: raidsRepelled,
    ),
    turnsPlayed: turns,
    totalNoise: noise,
    buildings: const {},
    baseUnits: const {},
    resources: const {},
    log: const [],
    milestones: ScriptMilestones()..failleCaptured = faille,
  );
}

void main() {
  group('BatchReport with no runs', () {
    final report = BatchReport(const []);

    test('reports zeros instead of dividing by zero', () {
      expect(report.games, 0);
      expect(report.survivalRate, 0);
      expect(report.averageTurns, 0);
      expect(report.averageNoise, 0);
      expect(report.earliestDefeat, isNull);
    });

    test('milestone has no games and no average', () {
      final m = report.milestone((r) => r.milestones.failleCaptured);
      expect(m.games, 0);
      expect(m.averageTurn, isNull);
    });
  });

  group('BatchReport over mixed runs', () {
    final report = BatchReport([
      _run(status: GameStatus.defeat, turns: 12, noise: 30, raidsLost: 2),
      _run(status: GameStatus.defeat, turns: 8, noise: 10, raidsLost: 1),
      _run(status: GameStatus.victory, turns: 40, noise: 50, faille: 10,
          raidsRepelled: 3),
      _run(turns: 20, noise: 10, faille: 20, raidsRepelled: 1),
    ]);

    test('counts games, defeats and victories', () {
      expect(report.games, 4);
      expect(report.defeats, 2);
      expect(report.victories, 1);
    });

    test('survival rate is the share of games not lost', () {
      expect(report.survivalRate, 0.5);
    });

    test('averages turns, raids and noise over every game', () {
      expect(report.averageTurns, 20);
      expect(report.averageRaidsLost, 0.75);
      expect(report.averageRaidsRepelled, 1);
      expect(report.averageNoise, 25);
    });

    test('earliest defeat is the smallest defeat turn', () {
      expect(report.earliestDefeat, 8);
    });

    test('milestone counts only runs that reached it', () {
      final m = report.milestone((r) => r.milestones.failleCaptured);
      expect(m.games, 2);
      expect(m.averageTurn, 15);
    });

    test('toJson exposes every aggregate', () {
      expect(report.toJson(), {
        'games': 4,
        'defeats': 2,
        'victories': 1,
        'survivalRate': 0.5,
        'averageTurns': 20.0,
        'averageRaidsLost': 0.75,
        'averageRaidsRepelled': 1.0,
        'averageNoise': 25.0,
        'earliestDefeat': 8,
      });
    });
  });

  test('runs list cannot be modified after construction', () {
    final source = [_run()];
    final report = BatchReport(source);
    source.add(_run());

    expect(report.games, 1);
    expect(() => report.runs.add(_run()), throwsUnsupportedError);
  });
}

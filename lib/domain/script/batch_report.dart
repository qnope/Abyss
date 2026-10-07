import 'script_run_report.dart';

/// Aggregate of many scripted games played with the same script.
class BatchReport {
  final List<ScriptRunReport> runs;

  BatchReport(List<ScriptRunReport> runs)
      : runs = List<ScriptRunReport>.unmodifiable(runs);

  int get games => runs.length;
  int get defeats => runs.where((r) => r.isDefeat).length;
  int get victories => runs.where((r) => r.isVictory).length;

  /// Share of games that did not end in defeat, from 0 to 1.
  double get survivalRate => games == 0 ? 0 : (games - defeats) / games;

  double get averageTurns => _average((r) => r.turnsPlayed);
  double get averageRaidsLost => _average((r) => r.raidsLost);
  double get averageRaidsRepelled => _average((r) => r.raidsRepelled);
  double get averageNoise => _average((r) => r.totalNoise);

  /// Earliest turn the base fell on, or `null` when it never did.
  int? get earliestDefeat {
    final List<int> turns = <int>[
      for (final r in runs)
        if (r.isDefeat) r.turnsPlayed,
    ];
    if (turns.isEmpty) return null;
    return turns.reduce((a, b) => a < b ? a : b);
  }

  double _average(num Function(ScriptRunReport) of) =>
      games == 0 ? 0 : runs.map(of).fold<num>(0, (a, b) => a + b) / games;

  Map<String, Object?> toJson() => <String, Object?>{
        'games': games,
        'defeats': defeats,
        'victories': victories,
        'survivalRate': survivalRate,
        'averageTurns': averageTurns,
        'averageRaidsLost': averageRaidsLost,
        'averageRaidsRepelled': averageRaidsRepelled,
        'averageNoise': averageNoise,
        'earliestDefeat': earliestDefeat,
      };
}

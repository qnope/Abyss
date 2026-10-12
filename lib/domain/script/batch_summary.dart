import 'batch_report.dart';
import 'script_milestones.dart';
import 'script_run_report.dart';

/// The summary of a batch the simulator prints, line by line: survival,
/// raids, the steps of the road to the volcano, the guardians' strike
/// back at the first Faille and the kraken waves on the kernel.
abstract final class BatchSummary {
  static List<String> linesOf(String name, BatchReport report) {
    String pct(double v) => '${(v * 100).toStringAsFixed(0)} %';
    String avg(double v) => v.toStringAsFixed(1);
    final List<ScriptRaid> waves = <ScriptRaid>[
      for (final ScriptRunReport r in report.runs) ...r.milestones.waves,
    ];
    return <String>[
      'Stratégie : $name, ${report.games} parties',
      'Survie : ${pct(report.survivalRate)} '
          '(${report.defeats} défaites, ${report.victories} victoires)',
      'Tours joués en moyenne : ${avg(report.averageTurns)}',
      'Raids repoussés / perdus en moyenne : '
          '${avg(report.averageRaidsRepelled)} / '
          '${avg(report.averageRaidsLost)}',
      'Bruit total moyen : ${avg(report.averageNoise)}',
      'Première défaite : tour ${report.earliestDefeat ?? '-'}',
      ..._milestone(report, 'Faille prise', (r) => r.milestones.failleCaptured),
      ..._milestone(
        report,
        'Cheminée prise',
        (r) => r.milestones.chemineeCaptured,
      ),
      ..._milestone(report, 'Noyau pris', (r) => r.milestones.kernelCaptured),
      ..._milestone(
        report,
        'Victoire',
        (r) => r.isVictory ? r.turnsPlayed : null,
      ),
      ..._milestone(report, 'Léviathan', (r) => r.milestones.leviathanStruck),
      ..._milestone(
        report,
        'Module perdu au Léviathan',
        (r) =>
            r.milestones.leviathanHeld == false
                ? r.milestones.leviathanStruck
                : null,
      ),
      if (waves.isNotEmpty)
        'Vagues du Noyau : ${waves.length} combattues, '
            '${waves.where((ScriptRaid w) => !w.victory).length} perdues',
    ];
  }

  /// The line of a milestone, none when no game reached it.
  static List<String> _milestone(
    BatchReport report,
    String label,
    int? Function(ScriptRunReport) turnOf,
  ) {
    final m = report.milestone(turnOf);
    if (m.games == 0) return const <String>[];
    return <String>[
      '$label : ${m.games}/${report.games} parties, '
          'tour ${m.averageTurn!.toStringAsFixed(1)} en moyenne',
    ];
  }
}

import 'package:flutter/material.dart';

import '../../../domain/history/history_entry.dart';
import '../../../domain/volcano/volcano_report.dart';
import '../../screens/game/volcano/volcano_summary_screen.dart';

/// Rebuilds a [VolcanoReport] from a persisted [VolcanoEntry] and opens
/// the kraken wave report screen.
Future<void> openVolcanoSummaryFromEntry(
  BuildContext context,
  VolcanoEntry entry,
) =>
    VolcanoSummaryScreen.open(
      context,
      VolcanoReport(
        turn: entry.turn,
        victory: entry.victory,
        wave: entry.wave,
        fight: entry.fightResult,
        kernelLevel: entry.kernelLevel,
        defenders: entry.defenders,
        survivorsIntact: entry.survivorsIntact,
        wounded: entry.wounded,
        dead: entry.dead,
      ),
    );

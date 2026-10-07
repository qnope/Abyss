import 'package:flutter/material.dart';

import '../../../domain/history/history_entry.dart';
import '../../../domain/raid/raid_report.dart';
import '../../screens/game/raid/raid_summary_screen.dart';

/// Rebuilds a [RaidReport] from a persisted [RaidEntry] and opens the
/// raid report screen.
Future<void> openRaidSummaryFromEntry(BuildContext context, RaidEntry entry) {
  final report = RaidReport(
    turn: entry.turn,
    victory: entry.victory,
    wave: entry.wave,
    fight: entry.fightResult,
    rampartLevel: entry.rampartLevel,
    defenders: entry.defenders,
    survivorsIntact: entry.survivorsIntact,
    wounded: entry.wounded,
    dead: entry.dead,
    loot: entry.loot,
    pillaged: entry.pillaged,
  );
  return RaidSummaryScreen.open(context, report);
}

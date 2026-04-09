import 'package:flutter/material.dart';

import '../../../domain/action/fight_monster_result.dart';
import '../../../domain/history/history_entry.dart';
import '../../screens/game/fight/fight_summary_screen.dart';

/// Rebuilds a [FightMonsterResult] from a persisted [CombatEntry] and
/// pushes the existing [FightSummaryScreen].
///
/// This helper lets the history view reuse the post-combat summary
/// screen as-is, without refactoring it into a dialog. The screen's
/// "Retour à la carte" button simply pops back to the sheet.
Future<void> openFightSummaryFromEntry(
  BuildContext context,
  CombatEntry entry,
) {
  final result = FightMonsterResult.success(
    victory: entry.victory,
    fight: entry.fightResult,
    loot: entry.loot,
    sent: entry.sent,
    survivorsIntact: entry.survivorsIntact,
    wounded: entry.wounded,
    dead: entry.dead,
  );
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => FightSummaryScreen(
        result: result,
        lair: entry.lair,
        targetX: entry.targetX,
        targetY: entry.targetY,
      ),
    ),
  );
}

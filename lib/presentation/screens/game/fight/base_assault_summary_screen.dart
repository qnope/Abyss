import 'package:flutter/material.dart';

import '../../../../domain/history/history_entry.dart';
import '../../../extensions/transition_base_name_extensions.dart';
import '../../../l10n/l10n_extension.dart';
import '../../../widgets/fight/assault_damage_card.dart';
import '../../../widgets/fight/fight_loot_card.dart';
import '../../../widgets/fight/fight_report_card.dart';
import '../../../widgets/fight/fight_result_banner.dart';
import '../../../widgets/fight/fight_turn_list.dart';
import '../../../widgets/fight/fight_unit_accounting.dart';
import '../raid/raid_pillage_card.dart';

/// Report of an assault on a base, read from the side of the owner of
/// [entry]: the attacker's own, just fought, or the one in the history.
/// Reuses the cards of the fight and raid reports.
class BaseAssaultSummaryScreen extends StatelessWidget {
  final BaseAssaultEntry entry;

  const BaseAssaultSummaryScreen({super.key, required this.entry});

  static Future<void> open(BuildContext context, BaseAssaultEntry entry) =>
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => BaseAssaultSummaryScreen(entry: entry),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final fight = entry.fightResult;
    final name = entry.opponentName;
    final defending = entry.defending;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.fightAssaultOn(name))),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          FightResultBanner(
            victory: entry.victory != defending,
            turnCount: fight.turnCount,
          ),
          const SizedBox(height: 12),
          FightReportCard.line(
            defending
                ? l10n.assaultAttackedYou(name)
                : l10n.assaultYouAttacked(name),
          ),
          const SizedBox(height: 12),
          FightUnitAccounting(
            sent: entry.units,
            intact: entry.survivorsIntact,
            wounded: entry.wounded,
            dead: entry.dead,
          ),
          const SizedBox(height: 12),
          FightReportCard.line(
            l10n.assaultDefendersDown(
              fight.initialMonsterCount - fight.finalMonsterCount,
              fight.initialMonsterCount,
            ),
          ),
          if (entry.victory && entry.postName != null) ...[
            const SizedBox(height: 12),
            FightReportCard.line(
              defending
                  ? l10n.assaultPostLost(baseNameLabel(l10n, entry.postName!))
                  : l10n.assaultPostTaken(baseNameLabel(l10n, entry.postName!)),
            ),
          ] else if (entry.victory) ...[
            const SizedBox(height: 12),
            AssaultDamageCard(entry: entry),
            const SizedBox(height: 12),
            defending
                ? RaidPillageCard(pillaged: entry.pillaged)
                : FightLootCard(loot: entry.loot),
          ],
          const SizedBox(height: 12),
          FightTurnList(summaries: fight.turnSummaries),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.commonBackToMap),
          ),
        ],
      ),
    );
  }
}

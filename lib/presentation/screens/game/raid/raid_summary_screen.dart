import 'package:flutter/material.dart';

import '../../../../domain/building/coral_citadel_rampart.dart';
import '../../../../domain/raid/raid_report.dart';
import '../../../l10n/l10n_extension.dart';
import '../../../theme/abyss_colors.dart';
import '../../../widgets/fight/fight_kill_count.dart';
import '../../../widgets/fight/fight_loot_card.dart';
import '../../../widgets/fight/fight_result_banner.dart';
import '../../../widgets/fight/fight_turn_list.dart';
import '../../../widgets/fight/fight_unit_accounting.dart';
import '../../../widgets/fight/monster_preview.dart';
import 'raid_pillage_card.dart';

/// Report of a raid on the base, or of a school of predators fought like
/// one. Reuses the fight report cards, plus the Citadel rampart and the
/// pillaged resources.
class RaidSummaryScreen extends StatelessWidget {
  final RaidReport report;

  const RaidSummaryScreen({super.key, required this.report});

  static Future<void> open(BuildContext context, RaidReport report) =>
      Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => RaidSummaryScreen(report: report),
      ));

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(report.surprise
            ? l10n.raidPredatorsTitle(report.turn)
            : l10n.raidTitle(report.turn)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          FightResultBanner(
            victory: report.victory,
            turnCount: report.fight.turnCount,
          ),
          const SizedBox(height: 12),
          MonsterPreview(lair: report.wave),
          if (report.rampartLevel > 0) ...[
            const SizedBox(height: 12),
            _rampartCard(context),
          ],
          if (report.defenders.isNotEmpty) ...[
            const SizedBox(height: 12),
            FightUnitAccounting(
              sent: report.defenders,
              intact: report.survivorsIntact,
              wounded: report.wounded,
              dead: report.dead,
            ),
          ],
          const SizedBox(height: 12),
          FightKillCount(fight: report.fight),
          const SizedBox(height: 12),
          report.victory
              ? FightLootCard(loot: report.loot)
              : RaidPillageCard(pillaged: report.pillaged),
          const SizedBox(height: 12),
          FightTurnList(summaries: report.fight.turnSummaries),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.commonBackToBase),
          ),
        ],
      ),
    );
  }

  Widget _rampartCard(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.fort, color: AbyssColors.coralPink),
        title: Text(context.l10n.raidRampart(report.rampartLevel)),
        subtitle: Text(CoralCitadelRampart.label(report.rampartLevel)),
      ),
    );
  }
}

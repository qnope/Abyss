import 'package:flutter/material.dart';

import '../../../../domain/action/fight_monster_result.dart';
import '../../../../domain/building/coral_citadel_rampart.dart';
import '../../../../domain/raid/raid_report.dart';
import '../../../theme/abyss_colors.dart';
import '../../../widgets/fight/fight_turn_list.dart';
import '../../../widgets/fight/monster_preview.dart';
import '../fight/fight_summary_screen_sections.dart';
import 'raid_pillage_card.dart';

/// Report of a raid on the base. Reuses the fight summary sections, plus
/// the Citadel rampart and the pillaged resources.
class RaidSummaryScreen extends StatelessWidget {
  final RaidReport report;

  const RaidSummaryScreen({super.key, required this.report});

  static Future<void> open(BuildContext context, RaidReport report) =>
      Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => RaidSummaryScreen(report: report),
      ));

  @override
  Widget build(BuildContext context) {
    final result = _asFightResult();
    return Scaffold(
      appBar: AppBar(title: Text('Raid sur la base (tour ${report.turn})')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          buildResultBanner(context, result),
          const SizedBox(height: 12),
          MonsterPreview(lair: report.wave),
          if (report.rampartLevel > 0) ...[
            const SizedBox(height: 12),
            _rampartCard(context),
          ],
          if (report.defenders.isNotEmpty) ...[
            const SizedBox(height: 12),
            buildPlayerAccounting(context, result),
          ],
          const SizedBox(height: 12),
          buildMonsterSection(context, result),
          const SizedBox(height: 12),
          report.victory
              ? buildLoot(context, result)
              : RaidPillageCard(pillaged: report.pillaged),
          const SizedBox(height: 12),
          FightTurnList(summaries: report.fight.turnSummaries),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Retour à la base'),
          ),
        ],
      ),
    );
  }

  FightMonsterResult _asFightResult() => FightMonsterResult.success(
        victory: report.victory,
        fight: report.fight,
        loot: report.loot,
        sent: report.defenders,
        survivorsIntact: report.survivorsIntact,
        wounded: report.wounded,
        dead: report.dead,
      );

  Widget _rampartCard(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.fort, color: AbyssColors.coralPink),
        title: Text('Rempart de la Citadelle niv. ${report.rampartLevel}'),
        subtitle: Text(CoralCitadelRampart.label(report.rampartLevel)),
      ),
    );
  }
}

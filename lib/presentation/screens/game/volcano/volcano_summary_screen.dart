import 'package:flutter/material.dart';

import '../../../../domain/action/fight_monster_result.dart';
import '../../../../domain/volcano/magma_rampart.dart';
import '../../../../domain/volcano/volcano_report.dart';
import '../../../theme/abyss_colors.dart';
import '../../../widgets/fight/fight_turn_list.dart';
import '../../../widgets/fight/monster_preview.dart';
import '../fight/fight_summary_screen_sections.dart';

/// Report of a kraken wave on the kernel. Reuses the fight summary
/// sections, plus the magma rampart and the kernel level at stake.
class VolcanoSummaryScreen extends StatelessWidget {
  final VolcanoReport report;

  const VolcanoSummaryScreen({super.key, required this.report});

  static Future<void> open(BuildContext context, VolcanoReport report) =>
      Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => VolcanoSummaryScreen(report: report),
      ));

  @override
  Widget build(BuildContext context) {
    final result = FightMonsterResult.success(
      victory: report.victory,
      fight: report.fight,
      loot: const {},
      sent: report.defenders,
      survivorsIntact: report.survivorsIntact,
      wounded: report.wounded,
      dead: report.dead,
    );
    return Scaffold(
      appBar: AppBar(title: Text('Vague sur le Noyau (tour ${report.turn})')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          buildResultBanner(context, result),
          const SizedBox(height: 12),
          _kernelCard(),
          const SizedBox(height: 12),
          MonsterPreview(lair: report.wave),
          if (report.defenders.isNotEmpty) ...[
            const SizedBox(height: 12),
            buildPlayerAccounting(context, result),
          ],
          const SizedBox(height: 12),
          buildMonsterSection(context, result),
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

  Widget _kernelCard() {
    final level = report.kernelLevel;
    return Card(
      child: ListTile(
        leading: Icon(
          Icons.volcano,
          color: report.victory ? AbyssColors.coralPink : AbyssColors.error,
        ),
        title: Text(report.victory
            ? 'Le Noyau tient au niveau $level'
            : 'Le Noyau retombe au niveau ${report.kernelLevelAfter}'),
        subtitle: level > 0
            ? Text('Rempart de magma : ${MagmaRampart.label(level)}')
            : null,
      ),
    );
  }
}

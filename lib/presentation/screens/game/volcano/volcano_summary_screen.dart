import 'package:flutter/material.dart';

import '../../../../domain/volcano/magma_rampart.dart';
import '../../../../domain/volcano/volcano_report.dart';
import '../../../l10n/l10n_extension.dart';
import '../../../theme/abyss_colors.dart';
import '../../../widgets/fight/fight_kill_count.dart';
import '../../../widgets/fight/fight_result_banner.dart';
import '../../../widgets/fight/fight_turn_list.dart';
import '../../../widgets/fight/fight_unit_accounting.dart';
import '../../../widgets/fight/monster_preview.dart';

/// Report of a kraken wave on the kernel. Reuses the fight report cards,
/// plus the magma rampart and the kernel level at stake.
class VolcanoSummaryScreen extends StatelessWidget {
  final VolcanoReport report;

  const VolcanoSummaryScreen({super.key, required this.report});

  static Future<void> open(BuildContext context, VolcanoReport report) =>
      Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => VolcanoSummaryScreen(report: report),
      ));

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.volcanoWaveTitle(report.turn))),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          FightResultBanner(
            victory: report.victory,
            turnCount: report.fight.turnCount,
          ),
          const SizedBox(height: 12),
          _kernelCard(context),
          const SizedBox(height: 12),
          MonsterPreview(lair: report.wave),
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

  Widget _kernelCard(BuildContext context) {
    final l10n = context.l10n;
    final level = report.kernelLevel;
    return Card(
      child: ListTile(
        leading: Icon(
          Icons.volcano,
          color: report.victory ? AbyssColors.coralPink : AbyssColors.error,
        ),
        title: Text(report.victory
            ? l10n.volcanoKernelHolds(level)
            : l10n.volcanoKernelDrops(report.kernelLevelAfter)),
        subtitle: level > 0
            ? Text(l10n.volcanoMagmaRampart(MagmaRampart.label(level)))
            : null,
      ),
    );
  }
}

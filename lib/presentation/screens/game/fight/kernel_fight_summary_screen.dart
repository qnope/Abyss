import 'package:flutter/material.dart';
import '../../../../domain/action/attack_volcanic_kernel_result.dart';
import '../../../l10n/l10n_extension.dart';
import '../../../widgets/fight/fight_kill_count.dart';
import '../../../widgets/fight/fight_result_banner.dart';
import '../../../widgets/fight/fight_turn_list.dart';
import '../../../widgets/fight/fight_unit_accounting.dart';

class KernelFightSummaryScreen extends StatelessWidget {
  final AttackVolcanicKernelResult result;
  final int targetX;
  final int targetY;

  const KernelFightSummaryScreen({
    super.key,
    required this.result,
    required this.targetX,
    required this.targetY,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final fight = result.fight;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.fightAssaultOn(l10n.buildingVolcanicKernelName)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          FightResultBanner(
            victory: result.victory,
            label: result.captured ? l10n.fightKernelCaptured : null,
            turnCount: fight?.turnCount,
          ),
          const SizedBox(height: 12),
          FightUnitAccounting(
            sent: result.sent,
            intact: result.survivorsIntact,
            wounded: result.wounded,
            dead: result.dead,
          ),
          if (fight != null) ...[
            const SizedBox(height: 12),
            FightKillCount(fight: fight, guardians: true),
            const SizedBox(height: 12),
            FightTurnList(summaries: fight.turnSummaries),
          ],
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

import 'package:flutter/material.dart';
import '../../../../domain/action/attack_transition_base_result.dart';
import '../../../../domain/map/transition_base.dart';
import '../../../l10n/l10n_extension.dart';
import '../../../widgets/fight/fight_kill_count.dart';
import '../../../widgets/fight/fight_result_banner.dart';
import '../../../widgets/fight/fight_turn_list.dart';
import '../../../widgets/fight/fight_unit_accounting.dart';

class TransitionFightSummaryScreen extends StatelessWidget {
  final AttackTransitionBaseResult result;
  final TransitionBase transitionBase;
  final int targetX;
  final int targetY;

  const TransitionFightSummaryScreen({
    super.key,
    required this.result,
    required this.transitionBase,
    required this.targetX,
    required this.targetY,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final fight = result.fight;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.fightAssaultTitle(targetX, targetY))),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          FightResultBanner(
            victory: result.victory,
            label: result.captured ? l10n.fightBaseCaptured : null,
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

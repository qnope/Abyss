import 'package:flutter/material.dart';
import '../../../../domain/action/fight_monster_result.dart';
import '../../../../domain/map/monster_lair.dart';
import '../../../l10n/l10n_extension.dart';
import '../../../widgets/fight/fight_kill_count.dart';
import '../../../widgets/fight/fight_loot_card.dart';
import '../../../widgets/fight/fight_result_banner.dart';
import '../../../widgets/fight/fight_turn_list.dart';
import '../../../widgets/fight/fight_unit_accounting.dart';
import '../../../widgets/fight/monster_preview.dart';

class FightSummaryScreen extends StatelessWidget {
  final FightMonsterResult result;
  final MonsterLair lair;
  final int targetX;
  final int targetY;

  const FightSummaryScreen({
    super.key,
    required this.result,
    required this.lair,
    required this.targetX,
    required this.targetY,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final fight = result.fight!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.fightTitle(targetX, targetY))),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          FightResultBanner(
              victory: result.victory, turnCount: fight.turnCount),
          const SizedBox(height: 12),
          MonsterPreview(lair: lair),
          const SizedBox(height: 12),
          FightUnitAccounting(
            sent: result.sent,
            intact: result.survivorsIntact,
            wounded: result.wounded,
            dead: result.dead,
          ),
          const SizedBox(height: 12),
          FightKillCount(fight: fight),
          if (result.victory) ...[
            const SizedBox(height: 12),
            FightLootCard(loot: result.loot),
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

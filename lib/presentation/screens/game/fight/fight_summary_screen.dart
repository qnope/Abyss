import 'package:flutter/material.dart';
import '../../../../domain/action/fight_monster_result.dart';
import '../../../../domain/map/monster_lair.dart';
import '../../../widgets/fight/fight_turn_list.dart';
import '../../../widgets/fight/monster_preview.dart';
import 'fight_summary_screen_sections.dart';

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
    return Scaffold(
      appBar: AppBar(title: Text('Combat ($targetX, $targetY)')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          buildResultBanner(context, result),
          const SizedBox(height: 12),
          MonsterPreview(lair: lair),
          const SizedBox(height: 12),
          buildPlayerAccounting(context, result),
          const SizedBox(height: 12),
          buildMonsterSection(context, result),
          if (result.victory) ...[
            const SizedBox(height: 12),
            buildLoot(context, result),
          ],
          const SizedBox(height: 12),
          FightTurnList(summaries: result.fight!.turnSummaries),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Retour à la carte'),
          ),
        ],
      ),
    );
  }
}

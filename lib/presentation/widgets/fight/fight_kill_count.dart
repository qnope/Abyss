import 'package:flutter/material.dart';

import '../../../domain/fight/fight_result.dart';
import '../../l10n/l10n_extension.dart';
import 'fight_report_card.dart';

/// How many of the enemies of [fight] were killed, counted as guardians
/// for an assault on a guarded place.
class FightKillCount extends StatelessWidget {
  final FightResult fight;
  final bool guardians;

  const FightKillCount({
    super.key,
    required this.fight,
    this.guardians = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final total = fight.initialMonsterCount;
    final killed = total - fight.finalMonsterCount;
    return FightReportCard.line(guardians
        ? l10n.fightGuardiansKilled(killed, total)
        : l10n.fightEnemiesKilled(killed, total));
  }
}

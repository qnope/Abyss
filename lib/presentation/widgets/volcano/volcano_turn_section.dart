import 'package:flutter/material.dart';

import '../../../domain/turn/turn_result.dart';
import '../../../domain/unit/unit_type.dart';
import '../../extensions/monster_lair_extensions.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/abyss_colors.dart';
import '../turn/summary_line.dart';

/// Volcano lines of the end-of-turn summary: the kraken wave just fought
/// on the kernel and the one just announced.
class VolcanoTurnSection extends StatelessWidget {
  final TurnResult result;

  const VolcanoTurnSection({super.key, required this.result});

  static bool hasContent(TurnResult result) =>
      result.volcano != null || result.announcedWave != null;

  @override
  Widget build(BuildContext context) {
    final fought = result.volcano;
    final announced = result.announcedWave;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        if (fought != null)
          SummaryLine(
            fought.victory ? Icons.shield : Icons.volcano,
            fought.victory
                ? 'Volcan : vague repoussée, ${_losses(fought.wounded, fought.dead)}'
                : 'Volcan : le Noyau retombe au niveau ${fought.kernelLevelAfter}',
            fought.victory ? AbyssColors.success : AbyssColors.error,
          ),
        if (announced != null)
          SummaryLine(
            Icons.warning_amber,
            'Le Kraken remonte : ${announced.waveLabel(context.l10n)} au prochain tour',
            AbyssColors.warning,
          ),
      ],
    );
  }

  static String _losses(Map<UnitType, int> wounded, Map<UnitType, int> dead) {
    final int w = wounded.values.fold<int>(0, (a, b) => a + b);
    final int d = dead.values.fold<int>(0, (a, b) => a + b);
    return '$w ${w > 1 ? 'blessés' : 'blessé'}, $d ${d > 1 ? 'morts' : 'mort'}';
  }
}

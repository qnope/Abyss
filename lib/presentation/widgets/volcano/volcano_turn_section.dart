import 'package:flutter/material.dart';

import '../../../domain/turn/turn_result.dart';
import '../../../domain/unit/unit_type.dart';
import '../../extensions/monster_lair_extensions.dart';
import '../../l10n/app_localizations.dart';
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
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        if (fought != null)
          SummaryLine(
            fought.victory ? Icons.shield : Icons.volcano,
            fought.victory
                ? l10n.volcanoRepelled(
                    _losses(l10n, fought.wounded, fought.dead))
                : l10n.volcanoKernelFell(fought.kernelLevelAfter),
            fought.victory ? AbyssColors.success : AbyssColors.error,
          ),
        if (announced != null)
          SummaryLine(
            Icons.warning_amber,
            l10n.volcanoKrakenRises(announced.waveLabel(l10n)),
            AbyssColors.warning,
          ),
      ],
    );
  }

  static String _losses(
    AppLocalizations l10n,
    Map<UnitType, int> wounded,
    Map<UnitType, int> dead,
  ) {
    final int w = wounded.values.fold<int>(0, (a, b) => a + b);
    final int d = dead.values.fold<int>(0, (a, b) => a + b);
    return '${l10n.volcanoWounded(w)}, ${l10n.volcanoDead(d)}';
  }
}

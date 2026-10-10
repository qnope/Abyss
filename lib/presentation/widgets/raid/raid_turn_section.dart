import 'package:flutter/material.dart';

import '../../../domain/turn/turn_result.dart';
import '../../extensions/monster_lair_extensions.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/abyss_colors.dart';
import '../turn/summary_line.dart';

/// Raid lines of the end-of-turn summary: the raid just fought and the
/// raid just announced.
class RaidTurnSection extends StatelessWidget {
  final TurnResult result;

  const RaidTurnSection({super.key, required this.result});

  static bool hasContent(TurnResult result) =>
      result.raid != null || result.announcedRaid != null;

  @override
  Widget build(BuildContext context) {
    final raid = result.raid;
    final announced = result.announcedRaid;
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        if (raid != null)
          SummaryLine(
            raid.victory ? Icons.shield : Icons.dangerous,
            raid.victory ? l10n.historyRaidRepelled : l10n.raidBaseLooted,
            raid.victory ? AbyssColors.success : AbyssColors.error,
          ),
        if (announced != null)
          SummaryLine(
            Icons.warning_amber,
            l10n.raidAnnounced(
              announced.waveLabel(l10n),
              result.announcedRaidTurn ?? 0,
            ),
            AbyssColors.warning,
          ),
      ],
    );
  }
}

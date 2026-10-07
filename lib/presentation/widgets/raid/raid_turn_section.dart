import 'package:flutter/material.dart';

import '../../../domain/turn/turn_result.dart';
import '../../extensions/monster_lair_extensions.dart';
import '../../theme/abyss_colors.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        if (raid != null)
          _line(
            raid.victory ? Icons.shield : Icons.dangerous,
            raid.victory ? 'Raid repoussé' : 'La base a été pillée',
            raid.victory ? AbyssColors.success : AbyssColors.error,
          ),
        if (announced != null)
          _line(
            Icons.warning_amber,
            'Un raid approche : ${announced.waveLabel}, '
                'fin du tour ${result.announcedRaidTurn}',
            AbyssColors.warning,
          ),
      ],
    );
  }

  Widget _line(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: TextStyle(color: color))),
      ]),
    );
  }
}

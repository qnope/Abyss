import 'package:flutter/material.dart';

import '../../../domain/event/random_event_type.dart';
import '../../../domain/game/player.dart';
import '../../extensions/random_event_type_extensions.dart';
import '../../theme/abyss_colors.dart';

/// Warning shown before ending a turn while an event still waits for a
/// choice: its prudent option will apply.
class EventPendingWarning extends StatelessWidget {
  final RandomEventType type;

  const EventPendingWarning({super.key, required this.type});

  /// The warning for [player], `null` when no event waits.
  static EventPendingWarning? of(Player player) {
    final state = player.eventState;
    return state.hasPending ? EventPendingWarning(type: state.pending!) : null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        Row(children: [
          const Icon(Icons.auto_awesome, color: AbyssColors.warning),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "${type.label} : sans choix, l'option prudente s'appliquera",
              style: const TextStyle(color: AbyssColors.warning),
            ),
          ),
        ]),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../../../domain/event/event_state.dart';
import '../../extensions/event_state_extensions.dart';
import '../../extensions/random_event_type_extensions.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/abyss_colors.dart';

/// Thin strip under the raid and volcano bars: the event waiting for a
/// choice, which reopens its card when tapped, the effect that lasts and
/// the wreck left on the map. Hidden when there is none.
class EventStatusBar extends StatelessWidget {
  final EventState state;
  final int currentTurn;

  /// Reopens the card of the pending event.
  final VoidCallback? onOpen;

  const EventStatusBar({
    super.key,
    required this.state,
    required this.currentTurn,
    this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final pending = state.hasPending ? state.pending : null;
    final countdowns = [
      state.effectCountdown(l10n, currentTurn),
      state.wreckCountdown(l10n, currentTurn),
    ].whereType<String>().toList();
    if (pending == null && countdowns.isEmpty) return const SizedBox.shrink();
    final style = Theme.of(context).textTheme.bodySmall;
    return Container(
      color: AbyssColors.surfaceDim,
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (pending != null)
            InkWell(
              onTap: onOpen,
              child: _line(
                Icons.auto_awesome,
                'Événement : ${pending.label(l10n)} — choisir',
                style?.copyWith(color: AbyssColors.biolumCyan),
              ),
            ),
          for (final text in countdowns)
            _line(
              Icons.hourglass_bottom,
              text,
              style?.copyWith(color: AbyssColors.warning),
            ),
        ],
      ),
    );
  }

  Widget _line(IconData icon, String text, TextStyle? style) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(children: [
        Icon(icon, size: 16, color: style?.color),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: style)),
      ]),
    );
  }
}

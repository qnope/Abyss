import 'package:flutter/material.dart';

import '../../extensions/random_event_type_extensions.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/abyss_colors.dart';
import '../common/illustrated_card.dart';
import 'event_card_data.dart';
import 'event_choice.dart';

/// Opens the card of [data]. Completes with the option chosen, or `null`
/// when the card is closed without a choice.
Future<bool?> showEventCard(BuildContext context, EventCardData data) =>
    showDialog<bool>(
      context: context,
      builder: (_) => EventCard(data: data),
    );

/// Dialog announcing a random event: its illustration, its name, two
/// lines telling what happens and its options, figures included.
class EventCard extends StatelessWidget {
  final EventCardData data;

  const EventCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) => IllustratedCard(
    illustration: data.type.illustration,
    title: data.type.label(context.l10n),
    lines: data.lines,
    actions: _actions(context),
  );

  List<Widget> _actions(BuildContext context) {
    if (data.choices.isEmpty) {
      return [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.commonGotIt),
        ),
      ];
    }
    return [
      for (final choice in data.choices) _ChoiceButton(choice: choice),
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(context.l10n.eventCardLater),
      ),
    ];
  }
}

/// One option of the card: the first one filled, the prudent one
/// outlined, disabled with its reason when closed.
class _ChoiceButton extends StatelessWidget {
  final EventChoice choice;

  const _ChoiceButton({required this.choice});

  @override
  Widget build(BuildContext context) {
    final refusal = choice.refusal;
    final VoidCallback? onPressed = refusal == null
        ? () => Navigator.pop(context, choice.accept)
        : null;
    final label = Text(choice.label, textAlign: TextAlign.center);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          choice.accept
              ? ElevatedButton(onPressed: onPressed, child: label)
              : OutlinedButton(onPressed: onPressed, child: label),
          if (refusal != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                refusal,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AbyssColors.warning,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

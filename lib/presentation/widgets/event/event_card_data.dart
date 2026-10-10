import '../../../domain/event/random_event_type.dart';
import '../../../domain/game/game.dart';
import '../../l10n/app_localizations.dart';
import 'event_card_texts.dart';
import 'event_choice.dart';

/// Everything an event card shows: the event, two lines telling what
/// happens and its choices, none for an event that only informs.
class EventCardData {
  final RandomEventType type;

  /// Two short lines under the title.
  final List<String> lines;

  /// The first option then the prudent one, or empty.
  final List<EventChoice> choices;

  const EventCardData({
    required this.type,
    required this.lines,
    this.choices = const [],
  });

  /// The card of [type] for the human player of [game], with the figures
  /// of the current turn, in the language of [l10n].
  factory EventCardData.of(
    AppLocalizations l10n,
    Game game,
    RandomEventType type,
  ) {
    final texts = EventCardTexts(l10n, game, game.humanPlayer);
    return EventCardData(
      type: type,
      lines: texts.linesOf(type),
      choices: texts.choicesOf(type),
    );
  }
}

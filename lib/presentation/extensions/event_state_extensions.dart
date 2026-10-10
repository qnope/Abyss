import '../../domain/event/effects/wreck_sites.dart';
import '../../domain/event/event_state.dart';
import '../../domain/event/random_event_type.dart';
import '../l10n/app_localizations.dart';
import 'random_event_type_extensions.dart';

/// Turns left, the current [turn] included, of something lasting through
/// [untilTurn] inclusive.
int turnsLeft(int untilTurn, int turn) => untilTurn - turn + 1;

/// e.g. « Tempête : encore 2 tours ».
String countdownText(AppLocalizations l10n, String label, int turns) =>
    l10n.eventCountdown(label, turns);

/// Countdowns of the random events of a player.
extension EventStateDisplay on EventState {
  /// « Épave : encore N tours » when the wreck lies at ([x], [y]) on
  /// [level] during [turn], `null` otherwise.
  String? wreckCountdownAt(
    AppLocalizations l10n,
    int x,
    int y,
    int level,
    int turn,
  ) {
    final at = wreckPosition;
    final until = wreckUntilTurn;
    if (at == null || until == null || level != WreckSites.level) return null;
    if (at.x != x || at.y != y) return null;
    return wreckCountdown(l10n, turn);
  }

  /// « Épave : encore N tours » while a wreck lies on the map.
  String? wreckCountdown(AppLocalizations l10n, int turn) {
    final until = wreckUntilTurn;
    if (wreckPosition == null || until == null) return null;
    final label = RandomEventType.wreck.label(l10n);
    return countdownText(l10n, label, turnsLeft(until, turn));
  }

  /// Countdown of the effect lasting during [turn], e.g. « Tempête :
  /// encore 2 tours », `null` when none applies.
  String? effectCountdown(AppLocalizations l10n, int turn) {
    final type = active;
    final until = activeUntilTurn;
    if (type == null || until == null || !isActive(type, turn)) return null;
    final name = type == RandomEventType.coldCurrent && heating
        ? l10n.eventColdCurrentHeated(type.label(l10n))
        : type.label(l10n);
    return countdownText(l10n, name, turnsLeft(until, turn));
  }
}

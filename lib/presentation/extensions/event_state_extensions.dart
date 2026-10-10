import '../../domain/event/effects/wreck_sites.dart';
import '../../domain/event/event_state.dart';
import '../../domain/event/random_event_type.dart';
import 'random_event_type_extensions.dart';

/// Turns left, the current [turn] included, of something lasting through
/// [untilTurn] inclusive.
int turnsLeft(int untilTurn, int turn) => untilTurn - turn + 1;

/// e.g. « Tempête : encore 2 tours ».
String countdownText(String label, int turns) =>
    '$label : encore $turns ${turns > 1 ? 'tours' : 'tour'}';

/// French countdowns of the random events of a player.
extension EventStateDisplay on EventState {
  /// « Épave : encore N tours » when the wreck lies at ([x], [y]) on
  /// [level] during [turn], `null` otherwise.
  String? wreckCountdownAt(int x, int y, int level, int turn) {
    final at = wreckPosition;
    final until = wreckUntilTurn;
    if (at == null || until == null || level != WreckSites.level) return null;
    if (at.x != x || at.y != y) return null;
    return wreckCountdown(turn);
  }

  /// « Épave : encore N tours » while a wreck lies on the map.
  String? wreckCountdown(int turn) {
    final until = wreckUntilTurn;
    if (wreckPosition == null || until == null) return null;
    return countdownText(RandomEventType.wreck.label, turnsLeft(until, turn));
  }

  /// Countdown of the effect lasting during [turn], e.g. « Tempête :
  /// encore 2 tours », `null` when none applies.
  String? effectCountdown(int turn) {
    final type = active;
    final until = activeUntilTurn;
    if (type == null || until == null || !isActive(type, turn)) return null;
    final name = type == RandomEventType.coldCurrent && heating
        ? '${type.label} (serres chauffées)'
        : type.label;
    return countdownText(name, turnsLeft(until, turn));
  }
}

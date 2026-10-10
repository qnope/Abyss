import '../raid/raid_report.dart';
import 'random_event_type.dart';

/// What the random events did while a turn ended.
class EventTurnOutcome {
  /// Event drawn this turn, if any; one with a choice waits for it
  /// during the next turn.
  final RandomEventType? drawn;

  /// Event left without a choice, settled with its prudent option.
  final RandomEventType? defaulted;

  /// School of predators faced this turn, fought at its end.
  final RaidReport? predators;

  const EventTurnOutcome({this.drawn, this.defaulted, this.predators});
}

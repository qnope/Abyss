import 'random_event_type.dart';

/// Whether the player decides how an event plays out.
extension RandomEventChoice on RandomEventType {
  /// Every event waits for a choice except the storm, which applies as
  /// soon as it is drawn.
  bool get hasChoice => this != RandomEventType.storm;
}

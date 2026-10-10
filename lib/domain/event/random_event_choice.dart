import 'random_event_type.dart';

/// Whether the player decides how an event plays out.
extension RandomEventChoice on RandomEventType {
  /// Every event waits for a choice but the storm, which applies as soon
  /// as it is drawn, and the wreck, sunk on the map for the player to go
  /// and search or not.
  bool get hasChoice =>
      this != RandomEventType.storm && this != RandomEventType.wreck;
}

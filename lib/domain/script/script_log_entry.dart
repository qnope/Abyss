import '../action/action_failure.dart';

/// One action a script tried, kept to replay or debug a game.
class ScriptLogEntry {
  final int turn;
  final String description;
  final bool success;

  /// Why the action failed, if it did.
  final ActionFailure? reason;

  const ScriptLogEntry({
    required this.turn,
    required this.description,
    required this.success,
    this.reason,
  });

  @override
  String toString() => success
      ? 'T$turn ✓ $description'
      : 'T$turn ✗ $description (${reason?.name})';
}

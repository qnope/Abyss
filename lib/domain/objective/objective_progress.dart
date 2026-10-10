/// How far a player is on an objective: [current] steps out of [target].
class ObjectiveProgress {
  final int current;
  final int target;

  /// [current] is capped at [target]: going further does not show.
  ObjectiveProgress(int current, this.target)
    : current = current.clamp(0, target);

  /// One-step progress, done when [met].
  ObjectiveProgress.flag(bool met) : this(met ? 1 : 0, 1);

  bool get isDone => current >= target;

  /// Both progresses summed, as one goal made of two.
  ObjectiveProgress operator +(ObjectiveProgress other) =>
      ObjectiveProgress(current + other.current, target + other.target);

  @override
  String toString() => '$current/$target';
}

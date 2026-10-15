/// One turn of a fight played on the map: what the army [dealt] to the
/// monsters and what it [taken] from them, in hit points.
class StrikeRound {
  final int dealt;
  final int taken;

  const StrikeRound({required this.dealt, required this.taken});

  @override
  bool operator ==(Object other) =>
      other is StrikeRound && other.dealt == dealt && other.taken == taken;

  @override
  int get hashCode => Object.hash(dealt, taken);

  @override
  String toString() => 'StrikeRound(dealt: $dealt, taken: $taken)';
}

import '../../unit/unit_type.dart';
import 'replay_variant.dart';

/// One action of an exported replay, as the human played it, waiting to
/// be played again by a `PlanScript`.
class PlanStep {
  /// Turn the step is due on in this variant.
  final int turn;

  /// Rank of the step in the original game, which keeps the order of the
  /// actions of a turn.
  final int rank;

  /// The action as the replay wrote it (`{"do": "recruit", ...}`).
  final Map<String, Object?> json;

  const PlanStep({required this.turn, required this.rank, required this.json});

  String get verb => json['do'] as String;

  int get level => json['level'] as int? ?? 1;

  /// Whether the step moves the game towards the volcano: a player keeps
  /// to it until it succeeds, whatever the variant's patience.
  bool get persistent => _road.contains(verb);

  /// Whether the step aims at a cell of the map.
  bool get onMap => json.containsKey('x');

  /// The action adapted to [variant]: recruits of fighters scaled, unit
  /// selections cut to [available] on the step's level, and the replay's
  /// dice dropped unless the variant keeps them. A descent keeps its seed
  /// on the same map, since it draws the level below. `null` when nothing
  /// is left to send.
  Map<String, Object?>? adapt(
    ReplayVariant variant,
    Map<UnitType, int> available,
  ) {
    final Map<String, Object?> out = Map<String, Object?>.from(json);
    final bool drawsMap = verb == 'descend' && variant.sameMap;
    if (!variant.sameDice && !drawsMap || !variant.sameMap) out.remove('seed');
    if (verb == 'recruit') {
      final String unit = json['unit'] as String;
      final int count = json['count'] as int;
      out['count'] = _fixed.contains(unit)
          ? count
          : (count * variant.army).round().clamp(1, count * 4);
    }
    final Object? units = json['units'];
    if (units is Map) {
      final Map<String, int> cut = <String, int>{};
      for (final MapEntry<Object?, Object?> e in units.entries) {
        final int have = available[_unitNamed(e.key.toString())] ?? 0;
        final int n = (e.value as int) < have ? e.value as int : have;
        if (n > 0) cut[e.key.toString()] = n;
      }
      if (cut.isEmpty) return null;
      out['units'] = cut;
    }
    return out;
  }

  static const Set<String> _road = <String>{
    'attackBase',
    'attackKernel',
    'descend',
  };

  /// Units no variant scales: scouts only explore, one admiral leads.
  static const Set<String> _fixed = <String>{'scout', 'abyssAdmiral'};

  static UnitType? _unitNamed(String name) {
    for (final UnitType t in UnitType.values) {
      if (t.name == name) return t;
    }
    return null;
  }
}

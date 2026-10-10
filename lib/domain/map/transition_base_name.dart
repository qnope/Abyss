import 'transition_base_type.dart';

/// Which transition base of its [type] a base is: the presentation words
/// it in the player's language ("Faille Alpha", "Alpha Rift"...).
///
/// Saves store it as its [code]. Older saves stored the French name
/// itself: [parse] reads both.
class TransitionBaseName {
  final TransitionBaseType type;

  /// Order among the bases of [type]: 0 for Alpha or the primary vent.
  final int rank;

  const TransitionBaseName(this.type, this.rank);

  /// How many bases of each type a map holds.
  static int countOf(TransitionBaseType type) => switch (type) {
    TransitionBaseType.faille => 4,
    TransitionBaseType.cheminee => 3,
  };

  /// Every name of [type], by rank.
  static List<TransitionBaseName> allOf(TransitionBaseType type) => [
    for (var rank = 0; rank < countOf(type); rank++)
      TransitionBaseName(type, rank),
  ];

  /// What a save stores, such as `faille:0`.
  String get code => '${type.name}:$rank';

  /// The name a save [stored], as a code or as an older French name;
  /// `null` for any other text.
  static TransitionBaseName? parse(String stored) =>
      _legacy[stored] ?? _fromCode(stored);

  static TransitionBaseName? _fromCode(String code) {
    final parts = code.split(':');
    if (parts.length != 2) return null;
    final rank = int.tryParse(parts[1]);
    for (final type in TransitionBaseType.values) {
      if (type.name == parts[0] && rank != null) {
        return TransitionBaseName(type, rank);
      }
    }
    return null;
  }

  static const _legacy = {
    'Faille Alpha': TransitionBaseName(TransitionBaseType.faille, 0),
    'Faille Beta': TransitionBaseName(TransitionBaseType.faille, 1),
    'Faille Gamma': TransitionBaseName(TransitionBaseType.faille, 2),
    'Faille Delta': TransitionBaseName(TransitionBaseType.faille, 3),
    'Cheminee Primaire': TransitionBaseName(TransitionBaseType.cheminee, 0),
    'Cheminee Secondaire': TransitionBaseName(TransitionBaseType.cheminee, 1),
    'Cheminee Tertiaire': TransitionBaseName(TransitionBaseType.cheminee, 2),
  };

  @override
  bool operator ==(Object other) =>
      other is TransitionBaseName && other.type == type && other.rank == rank;

  @override
  int get hashCode => Object.hash(type, rank);

  @override
  String toString() => code;
}

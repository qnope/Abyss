/// Shapes shared by the snapshots of the model's collections.
abstract final class SnapshotValues {
  /// A Dart map as the list of its `[key, value]` pairs, in the order it
  /// iterates: that order is part of the state (a fight lines the units
  /// up in it), and a canonical map would lose it by sorting its keys.
  static List<Object?> pairs<K, V>(
    Map<K, V> map,
    Object? Function(K key) key,
    Object? Function(V value) value,
  ) => <Object?>[
    for (final MapEntry<K, V> e in map.entries)
      <Object?>[key(e.key), value(e.value)],
  ];

  /// A count by enum value (units by type, resources by type), as pairs.
  static List<Object?> counts<K extends Enum>(Map<K, int> map) =>
      pairs<K, int>(map, name, (int count) => count);

  static List<Object?> names(Iterable<Enum> values) => <Object?>[
    for (final Enum value in values) value.name,
  ];

  static String name(Enum value) => value.name;

  /// A decoded JSON value where every object becomes the list of its
  /// pairs, so the order of its keys is kept.
  static Object? ordered(Object? json) => switch (json) {
    final Map<String, Object?> map => pairs<String, Object?>(
      map,
      (String key) => key,
      ordered,
    ),
    final List<Object?> list => <Object?>[
      for (final Object? item in list) ordered(item),
    ],
    _ => json,
  };
}

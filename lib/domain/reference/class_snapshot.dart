import 'player_ids.dart';

/// Writes one field of a [T] as a canonical value (see `CanonicalWriter`).
typedef FieldWriter<T> = Object? Function(T value, PlayerIds ids);

/// How the objects of one persisted class are written in a snapshot: a
/// map with one entry per field, named after the Dart field.
///
/// It declares what it writes, so a test can compare it with the
/// `@HiveField`s of the class and fail when a field is added to the model
/// and forgotten here: every persisted field is either in [fields] or in
/// [omitted], with the reason it is left out.
class ClassSnapshot<T> {
  /// Name of the Dart class, as in its source.
  final String className;

  /// The fields written, by the name of the Dart field.
  final Map<String, FieldWriter<T>> fields;

  /// Fields written under another key than their Dart name, which only
  /// tells how an old save stored them (`savedFallen` is `fallen`).
  final Map<String, String> renamed;

  /// Persisted fields this snapshot does not write, each with the reason.
  final Map<String, String> omitted;

  const ClassSnapshot(
    this.className,
    this.fields, {
    this.renamed = const <String, String>{},
    this.omitted = const <String, String>{},
  });

  /// The Dart names of the fields written.
  Iterable<String> get fieldNames => fields.keys;

  /// The key [field] is written under.
  String keyOf(String field) => renamed[field] ?? field;

  Map<String, Object?> of(T value, PlayerIds ids) => only(value, ids, null);

  Map<String, Object?>? orNull(T? value, PlayerIds ids) =>
      value == null ? null : of(value, ids);

  List<Object?> listOf(Iterable<T> values, PlayerIds ids) => <Object?>[
    for (final T value in values) of(value, ids),
  ];

  /// The fields of [value] named in [names]; all of them when `null`.
  Map<String, Object?> only(T value, PlayerIds ids, Set<String>? names) =>
      <String, Object?>{
        for (final MapEntry<String, FieldWriter<T>> e in fields.entries)
          if (names == null || names.contains(e.key))
            keyOf(e.key): e.value(value, ids),
      };
}

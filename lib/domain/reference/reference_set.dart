import 'dart:convert';

import 'reference_exporter.dart';
import 'reference_source.dart';

/// The reference games kept in the repository, each one a file that
/// names its own source: played again, it must give the same file.
class ReferenceSet {
  final ReferenceExporter exporter;

  const ReferenceSet(this.exporter);

  /// The source the reference file [text] was produced from.
  static ReferenceSource sourceOf(String text) => ReferenceSource.fromJson(
    (jsonDecode(text) as Map<String, Object?>)['source']!
        as Map<String, Object?>,
  );

  /// The file the game of the reference file [text] gives today.
  String regenerate(String text) => exporter.export(sourceOf(text)).game.text;

  /// Every file of [committed], by name, as it is today.
  Map<String, String> regenerateAll(Map<String, String> committed) => committed
      .map((String name, String text) => MapEntry(name, regenerate(text)));

  /// The names of the files of [committed] that [regenerated] changes.
  static List<String> stale(
    Map<String, String> committed,
    Map<String, String> regenerated,
  ) => <String>[
    for (final MapEntry<String, String> e in committed.entries)
      if (regenerated[e.key] != e.value) e.key,
  ];
}

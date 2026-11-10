import 'dart:io';

import 'vector_file.dart';

/// Writes the vector files and tells which ones of a folder are stale.
class VectorExporter {
  final List<VectorFile> files;

  const VectorExporter(this.files);

  /// Writes every file into [folder], created if missing, and removes
  /// the `.json` files of a vector that no longer exists.
  void writeTo(Directory folder) {
    folder.createSync(recursive: true);
    final Set<String> kept = {for (final file in files) file.fileName};
    for (final String name in _jsonIn(folder)) {
      if (!kept.contains(name)) File('${folder.path}/$name').deleteSync();
    }
    for (final VectorFile file in files) {
      File('${folder.path}/${file.fileName}').writeAsStringSync(file.render());
    }
  }

  /// Names of the files of [folder] that differ from a fresh export:
  /// changed, missing or no longer generated. Sorted, empty when
  /// [folder] is up to date.
  List<String> staleIn(Directory folder) {
    final Directory fresh = Directory.systemTemp.createTempSync('vectors');
    try {
      writeTo(fresh);
      return differing(fresh, folder);
    } finally {
      fresh.deleteSync(recursive: true);
    }
  }

  /// Names of the `.json` files that are not the same bytes in [a] and
  /// [b], or are in one only. Sorted.
  static List<String> differing(Directory a, Directory b) {
    final Set<String> names = {..._jsonIn(a), ..._jsonIn(b)};
    return [
      for (final String name in names.toList()..sort())
        if (_textOf(a, name) != _textOf(b, name)) name,
    ];
  }

  static List<String> _jsonIn(Directory folder) => [
    if (folder.existsSync())
      for (final FileSystemEntity entity in folder.listSync())
        if (entity is File && entity.path.endsWith('.json'))
          entity.uri.pathSegments.last,
  ];

  static String? _textOf(Directory folder, String name) {
    final File file = File('${folder.path}/$name');
    return file.existsSync() ? file.readAsStringSync() : null;
  }
}

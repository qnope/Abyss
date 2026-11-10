import 'dart:io';

/// The persisted classes of the model as their source declares them: for
/// each `@HiveType` class under `lib/`, the names of its `@HiveField`s.
/// Enums are left out: a snapshot writes them by name.
Map<String, Set<String>> hiveClassesOf(Directory lib) {
  final Map<String, Set<String>> classes = <String, Set<String>>{};
  final List<File> sources =
      lib
          .listSync(recursive: true)
          .whereType<File>()
          .where(
            (File f) => f.path.endsWith('.dart') && !f.path.endsWith('.g.dart'),
          )
          .toList();
  for (final File source in sources) {
    classes.addAll(hiveClassesIn(source.readAsStringSync()));
  }
  return classes;
}

final RegExp _type = RegExp(
  r'@HiveType\([^)]*\)\s*(?:(?://[^\n]*)\s*)*(class|enum)\s+(\w+)',
);

/// A `@HiveField`, then the annotations and comments before the field,
/// then its declaration up to its name.
final RegExp _field = RegExp(
  r'@HiveField\([^)]*\)\s*'
  r'(?:(?:@\w+|//[^\n]*)\s*)*'
  r'(?:late\s+)?(?:final\s+)?[\w<>?,. ]+?\s+(\w+)\s*[;=]',
);

Map<String, Set<String>> hiveClassesIn(String source) {
  final Map<String, Set<String>> classes = <String, Set<String>>{};
  final List<RegExpMatch> types = _type.allMatches(source).toList();
  for (int i = 0; i < types.length; i++) {
    if (types[i].group(1) == 'enum') continue;
    final int end = i + 1 < types.length ? types[i + 1].start : source.length;
    final String body = source.substring(types[i].end, end);
    final int declared = '@HiveField('.allMatches(body).length;
    final Set<String> fields = <String>{
      for (final RegExpMatch m in _field.allMatches(body)) m.group(1)!,
    };
    if (fields.length != declared) {
      throw StateError(
        '${types[i].group(2)}: $declared @HiveField but ${fields.length} '
        'field names read; teach hive_source.dart the new syntax',
      );
    }
    classes[types[i].group(2)!] = fields;
  }
  return classes;
}

import 'vector_json.dart';

/// Cases of one Dart API: inputs and what the Dart code answers.
class VectorSection {
  /// The Dart call that computed every `out`, for the port to call its
  /// own.
  final String api;

  final List<Object?> Function() _cases;

  const VectorSection(this.api, this._cases);

  List<Object?> cases() => _cases();
}

/// One file of vectors: a few sections on the same subject.
class VectorFile {
  /// Name of the file, without `.json`.
  final String name;

  /// The sections by name.
  final Map<String, VectorSection> sections;

  const VectorFile(this.name, this.sections);

  String get fileName => '$name.json';

  /// The text of the file: the API of each section, then its cases, one
  /// per line.
  String render() => VectorJson.encode({
    'name': name,
    'api': {for (final e in sections.entries) e.key: e.value.api},
    'sections': {for (final e in sections.entries) e.key: e.value.cases()},
  });
}

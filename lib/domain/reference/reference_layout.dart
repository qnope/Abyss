import 'dart:convert';

/// A JSON text already written, put as it is in a [ReferenceLayout].
class RawJson {
  final String text;

  const RawJson(this.text);
}

/// Lays a JSON value out for a file kept in the repository: the
/// containers at the paths of [exploded] put each of their items on a
/// line of its own, everything else is compact. A change of the game then
/// shows as the lines of the turns it changes.
///
/// The keys keep the order they were given in: the order of the keys of
/// an action of the journal is the order it sends its units in.
class ReferenceLayout {
  /// Paths of the containers to explode, the keys joined by dots; the
  /// empty path is the value itself.
  final Set<String> exploded;

  const ReferenceLayout(this.exploded);

  String write(Object? value) {
    final StringBuffer out = StringBuffer();
    _write(value, '', out);
    out.writeln();
    return out.toString();
  }

  void _write(Object? value, String path, StringBuffer out) {
    if (value is RawJson) {
      out.write(value.text);
    } else if (!exploded.contains(path)) {
      out.write(jsonEncode(value));
    } else if (value is Map<String, Object?>) {
      _lines(out, '{', '}', value.entries, (MapEntry<String, Object?> e) {
        out.write('${jsonEncode(e.key)}:');
        _write(e.value, path.isEmpty ? e.key : '$path.${e.key}', out);
      });
    } else {
      _lines(
        out,
        '[',
        ']',
        value! as List<Object?>,
        (Object? item) => _write(item, '$path[]', out),
      );
    }
  }

  static void _lines<T>(
    StringBuffer out,
    String open,
    String close,
    Iterable<T> items,
    void Function(T item) write,
  ) {
    out.write(open);
    String separator = '\n';
    for (final T item in items) {
      out.write(separator);
      write(item);
      separator = ',\n';
    }
    out.write(items.isEmpty ? close : '\n$close');
  }
}

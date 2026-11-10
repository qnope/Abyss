import 'dart:typed_data';

/// Writes a value as the canonical text of the reference games, a strict
/// subset of JSON that GDScript reproduces byte for byte (see
/// `reference/README.md`):
///
/// - no whitespace;
/// - map keys are strings, sorted by UTF-16 code unit;
/// - integers in decimal;
/// - a double is never a number: it is the string `d:` followed by the 16
///   lowercase hex digits of its IEEE-754 bits, and NaN is refused;
/// - a string escapes only `"`, `\` and the characters below 0x20 (as
///   `\u00xx`); everything else is written raw.
abstract final class CanonicalWriter {
  /// Throws an [ArgumentError] on anything but null, a bool, an int, a
  /// double, a String, a List or a Map with String keys, however deep.
  static String write(Object? value) {
    final StringBuffer out = StringBuffer();
    _write(value, out);
    return out.toString();
  }

  static void _write(Object? value, StringBuffer out) {
    switch (value) {
      case null:
        out.write('null');
      case bool _ || int _:
        out.write(value);
      case double _:
        _writeString(_doubleText(value), out);
      case String _:
        _writeString(value, out);
      case List<Object?> _:
        _writeList(value, out);
      case Map<String, Object?> _:
        _writeMap(value, out);
      default:
        throw ArgumentError.value(
          value,
          'value',
          'not a canonical value (${value.runtimeType})',
        );
    }
  }

  static void _writeList(List<Object?> list, StringBuffer out) {
    out.write('[');
    for (int i = 0; i < list.length; i++) {
      if (i > 0) out.write(',');
      _write(list[i], out);
    }
    out.write(']');
  }

  static void _writeMap(Map<String, Object?> map, StringBuffer out) {
    // String.compareTo orders by UTF-16 code unit.
    final List<String> keys = map.keys.toList()..sort();
    out.write('{');
    for (int i = 0; i < keys.length; i++) {
      if (i > 0) out.write(',');
      _writeString(keys[i], out);
      out.write(':');
      _write(map[keys[i]], out);
    }
    out.write('}');
  }

  /// `d:` and the bits of [value], big-endian, in hex.
  static String _doubleText(double value) {
    if (value.isNaN) {
      throw ArgumentError.value(value, 'value', 'NaN has no canonical text');
    }
    final ByteData bits = ByteData(8)..setFloat64(0, value);
    String half(int offset) =>
        bits.getUint32(offset).toRadixString(16).padLeft(8, '0');
    return 'd:${half(0)}${half(4)}';
  }

  static void _writeString(String text, StringBuffer out) {
    out.write('"');
    int written = 0;
    for (int i = 0; i < text.length; i++) {
      final int unit = text.codeUnitAt(i);
      if (unit >= 0x20 && unit != 0x22 && unit != 0x5c) continue;
      out.write(text.substring(written, i));
      written = i + 1;
      out.write(switch (unit) {
        0x22 => r'\"',
        0x5c => r'\\',
        _ => '\\u00${unit.toRadixString(16).padLeft(2, '0')}',
      });
    }
    out.write(text.substring(written));
    out.write('"');
  }
}

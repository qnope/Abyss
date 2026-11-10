import 'dart:convert';
import 'dart:typed_data';

/// The JSON of the vectors: what the GDScript port reads back exactly.
///
/// Only maps, lists, strings, whole numbers, booleans and null. A double
/// is never a JSON number but `d:` and the 16 hex digits of its bits; a
/// whole number no double holds (Godot reads every JSON number as one)
/// is `i:` and its decimal digits; an enum is its name. Keys are sorted,
/// so the same value always gives the same bytes.
abstract final class VectorJson {
  /// Largest whole number every double up to it holds exactly: 2^53.
  static const int maxExact = 9007199254740992;

  /// [value] as the text of a vector file. The levels above [inlineFrom]
  /// take one line per entry, the ones below are written on one line.
  static String encode(Object? value, {int inlineFrom = 3}) {
    final out = StringBuffer();
    _write(out, plain(value), 0, inlineFrom);
    out.write('\n');
    return out.toString();
  }

  /// [value] with only what JSON holds, see the class.
  static Object? plain(Object? value) => switch (value) {
    null || bool() => value,
    String() => _text(value),
    int() => value.abs() > maxExact || value == -value && value != 0
        ? 'i:$value'
        : value,
    double() => 'd:${bitsOf(value)}',
    Enum() => value.name,
    Map() => _map(value),
    Iterable() => [for (final item in value) plain(item)],
    _ => throw ArgumentError.value(value, 'value', 'not a vector value'),
  };

  /// [map] as a list of `[key, value]`, for a map whose order matters:
  /// a JSON object is sorted by key and would lose it.
  static List<Object?> pairs(Map<Object?, Object?> map) => [
    for (final entry in map.entries) [plain(entry.key), plain(entry.value)],
  ];

  /// The 16 lowercase hex digits of the IEEE-754 bits of [value], the
  /// sign first; every NaN is written as the same quiet one.
  static String bitsOf(double value) {
    if (value.isNaN) return '7ff8000000000000';
    final bytes = ByteData(8)..setFloat64(0, value);
    return [
      for (var i = 0; i < 8; i++)
        bytes.getUint8(i).toRadixString(16).padLeft(2, '0'),
    ].join();
  }

  static String _text(String value) {
    if (value.startsWith('d:') || value.startsWith('i:')) {
      throw ArgumentError.value(value, 'value', 'reads as a number');
    }
    return value;
  }

  static Map<String, Object?> _map(Map<Object?, Object?> map) {
    final result = <String, Object?>{};
    for (final entry in map.entries) {
      final String key = switch (entry.key) {
        final String k => k,
        final int k => '$k',
        final Enum k => k.name,
        final k => throw ArgumentError.value(k, 'key', 'not a vector key'),
      };
      if (result.containsKey(key)) {
        throw ArgumentError.value(key, 'key', 'written twice');
      }
      result[key] = plain(entry.value);
    }
    return result;
  }

  static void _write(StringBuffer out, Object? value, int depth, int inline) {
    final bool isMap = value is Map<String, Object?>;
    if (!isMap && value is! List<Object?>) {
      out.write(jsonEncode(value));
      return;
    }
    final List<String> keys = isMap ? (value.keys.toList()..sort()) : const [];
    final int length = isMap ? keys.length : (value as List<Object?>).length;
    final bool spread = depth < inline && length > 0;
    final String pad = spread ? '\n${' ' * (depth + 1)}' : '';
    out.write(isMap ? '{' : '[');
    for (var i = 0; i < length; i++) {
      out.write(i == 0 ? pad : ',$pad');
      if (isMap) out.write('${jsonEncode(keys[i])}:${spread ? ' ' : ''}');
      final item = isMap ? value[keys[i]] : (value as List<Object?>)[i];
      _write(out, item, depth + 1, inline);
    }
    if (spread) out.write('\n${' ' * depth}');
    out.write(isMap ? '}' : ']');
  }
}

import 'dart:convert';
import 'dart:typed_data';

import 'package:abyss/domain/fight/combat_side.dart';
import 'package:abyss/domain/fight/combatant.dart';

import '../../../../tool/vectors/vector_file.dart';

/// A vector file as a port reads it: the JSON alone, nothing of the
/// Dart objects it was written from.
class VectorReader {
  final Map<String, Object?> _sections;

  VectorReader(VectorFile file)
    : _sections =
          (jsonDecode(file.render()) as Map<String, Object?>)['sections']!
              as Map<String, Object?>;

  List<Map<String, Object?>> cases(String section) =>
      (_sections[section]! as List<Object?>).cast<Map<String, Object?>>();

  /// The `out` of every case of [section].
  List<Object?> outs(String section) => [
    for (final c in cases(section)) c['out'],
  ];

  /// Every value written under [key] in the cases of [section].
  Set<Object?> valuesOf(String section, String key) => {
    for (final c in cases(section)) c[key],
  };

  /// The double written as `d:` and its bits.
  static double number(Object? written) {
    final String bits = (written! as String).substring(2);
    final ByteData bytes = ByteData(8);
    for (var i = 0; i < 8; i++) {
      bytes.setUint8(i, int.parse(bits.substring(2 * i, 2 * i + 2), radix: 16));
    }
    return bytes.getFloat64(0);
  }

  /// The fresh combatants of a side written as runs.
  static List<Combatant> side(Object? runs) => [
    for (final List<Object?> run in (runs! as List<Object?>).cast())
      for (var i = 0; i < (run[6]! as int); i++)
        Combatant(
          typeKey: run[0]! as String,
          side: CombatSide.values.byName(run[1]! as String),
          maxHp: run[2]! as int,
          atk: run[3]! as int,
          def: run[4]! as int,
          isBoss: run[5]! as bool,
        ),
  ];
}

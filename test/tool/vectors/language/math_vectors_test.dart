import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/vectors/language/math_literals.dart';
import '../../../../tool/vectors/language/math_vectors.dart';

List<Map<String, Object?>> _cases(String section) =>
    MathVectors.file.sections[section]!.cases().cast<Map<String, Object?>>();

Map<String, Object?> _out(Map<String, Object?> c) =>
    c['out']! as Map<String, Object?>;

/// The double literals written in the rules, comments left out.
Set<String> _literalsOfDomain() {
  final literal = RegExp(r'(?<![\w.])\d+\.\d+(?![\w.])');
  final found = <String>{};
  for (final entity in Directory('lib/domain').listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    if (entity.path.endsWith('.g.dart')) continue;
    for (final String line in entity.readAsLinesSync()) {
      final String code = line.split('//').first;
      found.addAll(literal.allMatches(code).map((m) => m[0]!));
    }
  }
  return found;
}

void main() {
  group('MathVectors, whole numbers', () {
    test('divide with negative operands, the modulo never negative', () {
      final cases = _cases('intDivision');
      expect(cases.where((c) => (c['a']! as int) < 0), isNotEmpty);
      expect(cases.where((c) => (c['b']! as int) < 0), isNotEmpty);
      for (final c in cases) {
        final a = c['a']! as int, b = c['b']! as int;
        final out = _out(c);
        expect(out['modulo']! as int, greaterThanOrEqualTo(0));
        expect((out['truncDiv']! as int) * b + (out['remainder']! as int), a);
      }
      final seven = cases.firstWhere((c) => c['a'] == -7 && c['b'] == 2);
      expect(_out(seven), {'truncDiv': -3, 'modulo': 1, 'remainder': -1});
    });

    test('tell a division by zero throws', () {
      for (final c in _cases('divisionByZero')) {
        expect(c['truncDivThrows'], isTrue);
        expect(c['moduloThrows'], isTrue);
      }
    });

    test('wrap to 64 bits and shift with and without the sign', () {
      final cases = _cases('bits');
      final wrapped = cases.firstWhere(
        (c) => c['a'] == 0xFFFFFFFF && c['b'] == 0xffffda61,
      );
      expect(_out(wrapped)['mul'], -41369124985441);
      final shifted = cases.firstWhere((c) => c['a'] == -1 && c['b'] == 63);
      expect(_out(shifted)['shr'], -1);
      expect(_out(shifted)['ushr'], 1);
      expect(_out(shifted)['shl'], -9223372036854775808);
    });
  });

  group('MathVectors, doubles', () {
    test('round halves away from zero, on both sides of it', () {
      int rounded(double x) =>
          _out(_cases('rounding').firstWhere((c) => c['x'] == x))['round']!
              as int;
      expect(rounded(0.5), 1);
      expect(rounded(-0.5), -1);
      expect(rounded(2.5), 3);
      expect(rounded(-2.5), -3);
      expect(rounded(0.49999999999999994), 0);
      expect(rounded(1e300), 9223372036854775807);
    });

    test('tell NaN and the infinities cannot be rounded', () {
      expect(_cases('notFinite').map((c) => c['throws']), [true, true, true]);
    });

    test('divide two ints into a double', () {
      final c = _cases('quotient').firstWhere(
        (c) => c['a'] == 7 && c['b'] == 4,
      );
      expect(_out(c), {'quotient': 1.75, 'round': 2, 'floor': 1, 'ceil': 2});
    });

    test('raise to a power only where every machine agrees', () {
      final powers = _cases('pow');
      expect(powers.where((c) => c['out'] is int), isNotEmpty);
      expect(powers.where((c) => c['out'] is double), isNotEmpty);
      final half = powers.firstWhere((c) => c['base'] == 2 && c['exponent'] == -1);
      expect(half['out'], 0.5);
      // 1.6^n is not exact past n = 1: its last bit is the C library's.
      for (final c in powers.where((c) => c['base'] == 1.6)) {
        expect(c['exponent'], lessThan(2));
      }
    });

    test('keep the type of the operand min, max and clamp return', () {
      final c = _cases('minMax').firstWhere(
        (c) => c['a'] == 1 && c['b'] is double,
      );
      expect(_out(c)['max'], isA<int>());
      final clamped = _cases('clamp').firstWhere((c) => c['x'] == 5001);
      expect(clamped['out'], 5000);
      expect(_cases('clamp').last['throws'], isTrue);
    });

    test('hold every double literal of the rules', () {
      final listed = MathLiterals.values.keys.toSet();
      expect(listed, containsAll(_literalsOfDomain()));
      expect(
        _cases('literals').map((c) => c['text']),
        MathLiterals.values.keys,
      );
    });
  });
}

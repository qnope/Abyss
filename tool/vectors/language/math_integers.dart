import '../vector_file.dart';

/// Whole-number arithmetic of Dart on the VM: 64 bits that wrap, `~/`
/// truncating towards zero, `%` never negative.
abstract final class MathIntegers {
  static const List<int> _dividends = <int>[
    0, 1, -1, 5, -5, 7, -7, 17, -17, 99, -99, 100, -100, 199, -199,
    1000000007, -1000000007, 9007199254740993, -9007199254740993,
  ];

  static const List<int> _divisors = <int>[
    1, -1, 2, -2, 3, -3, 7, -7, 10, -10, 100, -100, 400, 10000,
  ];

  static const int _max = 9223372036854775807;
  static const int _min = -9223372036854775808;

  /// Operands of [bits]: the edges of 32 and 64 bits, the constants of
  /// the generator and of the seeds the rules derive.
  static const List<(int, int)> _pairs = <(int, int)>[
    (0, 0), (1, 1), (-1, 1), (12, 5), (-12, 5), (0xFFFFFFFF, 0xffffda61),
    (0xffffda61, 0xFFFFFFFF), (_max, 1), (_min, 1), (_max, _max),
    (_min, -1), (_max, 2), (0x7FFFFFFF, 7919), (2147483646, 0x5FAC7),
    (123456789, 31), (-123456789, 31), (1, 62), (1, 63), (-1, 63),
    (0x123456789ABCDEF, 32), (-0x123456789ABCDEF, 32), (400, 21),
    (-400, 24), (1640531527, 28), (-2, 14), (17, 0x7FFFFFFF),
  ];

  static final Map<String, VectorSection> sections = {
    'intDivision': VectorSection(
      'a ~/ b (truncDiv), a % b (modulo) and a.remainder(b), a and b int',
      () => [
        for (final int a in _dividends)
          for (final int b in _divisors)
            {
              'a': a,
              'b': b,
              'out': {
                'truncDiv': a ~/ b,
                'modulo': a % b,
                'remainder': a.remainder(b),
              },
            },
      ],
    ),
    'divisionByZero': VectorSection(
      'a ~/ 0 and a % 0 throw (UnsupportedError), a int',
      () => [
        for (final int a in const [0, 7, -7])
          {
            'a': a,
            'truncDivThrows': _throws(() => a ~/ _zero),
            'moduloThrows': _throws(() => a % _zero),
          },
      ],
    ),
    'bits': VectorSection(
      'a + b, a - b, a * b (wrapping to 64 bits), a & b, a | b, a ^ b, '
          '-a, ~a, a.bitLength, a & -a (lowestBit), then with '
          's = b.abs() % 64: a << s (shl), a >> s (shr, keeps the sign) '
          'and a >>> s (ushr, fills with zeros)',
      () => [
        for (final (int a, int b) in _pairs)
          {'a': a, 'b': b, 'out': bits(a, b)},
      ],
    ),
    'abs': VectorSection(
      'a.abs(), a int; the smallest int is its own abs',
      () => [
        for (final int a in const [0, 5, -5, _max, -_max, _min])
          {'a': a, 'out': a.abs()},
      ],
    ),
  };

  /// Never a constant, so the division by it is left to run.
  static final int _zero = int.parse('0');

  static Map<String, int> bits(int a, int b) {
    final int s = b.abs() % 64;
    return {
      'add': a + b,
      'sub': a - b,
      'mul': a * b,
      'and': a & b,
      'or': a | b,
      'xor': a ^ b,
      'neg': -a,
      'not': ~a,
      'bitLength': a.bitLength,
      'lowestBit': a & -a,
      'shift': s,
      'shl': a << s,
      'shr': a >> s,
      'ushr': a >>> s,
    };
  }

  static bool _throws(int Function() compute) {
    try {
      compute();
      return false;
    } on UnsupportedError {
      return true;
    }
  }
}

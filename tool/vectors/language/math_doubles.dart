import 'dart:math';

import '../vector_file.dart';
import 'math_literals.dart';

/// Arithmetic of Dart on doubles and from doubles to whole numbers.
abstract final class MathDoubles {
  /// Halves, their neighbours, the limits of exactness and of 64 bits.
  static final List<double> _toRound = <double>[
    for (var k = -20; k <= 20; k++) k / 8,
    0.49999999999999994, -0.49999999999999994, 0.5000000000000001,
    6.75, 13.5, 14.5, -13.5, 1e-320, 4503599627370495.5,
    9007199254740991.0, 9007199254740993.0, 1e15, 1e18,
    9223372036854775807.0, -9223372036854775808.0, 1e19, -1e19, 1e300,
    -0.0,
  ];

  /// `a / b` as the rules write it: a boosted stat, a share of an army.
  static const List<(int, int)> _quotients = <(int, int)>[
    (270, 100), (1350, 100), (675, 100), (250, 100), (350, 100), (15, 20),
    (30, 20), (50, 20), (10, 20), (7, 4), (-7, 4), (7, -4), (-7, -4),
    (1, 3), (2, 3), (17, 20), (19, 20), (0, 8), (8, 8), (-1, 2), (1, 2),
    (3, 2), (-3, 2), (5, 2), (9007199254740993, 2), (1, 0), (-1, 0),
  ];

  static const List<(num, num, num)> _clamps = <(num, num, num)>[
    (5, 0, 10), (-5, 0, 10), (15, 0, 10), (0, 0, 0), (7, 7, 7), (-3, -9, -4),
    (3, 0, 3), (4999, 0, 5000), (5001, 0, 5000), (1.5, 0, 1), (-0.0, 0, 1),
    (0.25, 0.5, 0.75), (2, 1.5, 3.5), (5, 10, 0),
  ];

  static const List<(num, num)> _pairs = <(num, num)>[
    (1, 2), (2, 1), (-1, -2), (3, 3), (1, 1.0), (1.0, 1), (0.625, 0.725),
    (0.625, 0.5), (2, 1.5), (1.5, 2), (0, -0.0), (-0.0, 0), (0.0, -0.0),
    (-0.0, 0.0), (9007199254740993, 9007199254740992.0),
  ];

  static final Map<String, VectorSection> sections = {
    'rounding': VectorSection(
      'x.round() (half away from zero), x.floor(), x.ceil(), x.truncate() '
          'and x.toInt() of a double x: beyond 64 bits they give the '
          'nearest int',
      () => [
        for (final double x in _toRound)
          {
            'x': x,
            'out': {
              'round': x.round(),
              'floor': x.floor(),
              'ceil': x.ceil(),
              'truncate': x.truncate(),
              'toInt': x.toInt(),
            },
          },
      ],
    ),
    'notFinite': VectorSection(
      'x.round(), x.floor(), x.ceil() and x.toInt() throw '
          '(UnsupportedError) for a NaN or an infinite x',
      () => [
        for (final double x in [double.nan, double.infinity, -double.infinity])
          {'x': x, 'throws': _throws(x)},
      ],
    ),
    'quotient': VectorSection(
      'q = a / b, a and b int: a double, never a whole division; then '
          'q.round(), q.floor() and q.ceil(), null when q is not finite',
      () => [
        for (final (int a, int b) in _quotients)
          {'a': a, 'b': b, 'out': _quotient(a / b)},
      ],
    ),
    'pow': VectorSection(
      'pow(base, exponent) of dart:math: a double as soon as an operand '
          'is one, an int for two ints and exponent >= 0. Only results a '
          'double holds exactly: the last bit of the others is the C '
          'library\'s (see the README)',
      () => [
        for (final (num b, num e) in const <(num, num)>[
          (2, 10), (2, 62), (2, 63), (2, 64), (3, 40), (-3, 3), (2, -1),
          (2.0, 10), (10, 2.0), (4, 0.5), (0.5, 3), (1.6, 0), (1.6, 1),
          (0, 0), (0.0, 0),
        ])
          {'base': b, 'exponent': e, 'out': pow(b, e)},
      ],
    ),
    'clamp': VectorSection(
      'x.clamp(low, high): the operand it returns, so an int stays an '
          'int; throws (ArgumentError) when low > high',
      () => [
        for (final (num x, num low, num high) in _clamps)
          {'x': x, 'low': low, 'high': high, ..._clamp(x, low, high)},
      ],
    ),
    'minMax': VectorSection(
      'min(a, b) and max(a, b) of dart:math: the operand they return, '
          'the first one for equal numbers of two types',
      () => [
        for (final (num a, num b) in _pairs)
          {
            'a': a,
            'b': b,
            'out': {'min': min(a, b), 'max': max(a, b)},
          },
        {
          'a': double.nan,
          'b': 1,
          'out': {'min': min(double.nan, 1), 'max': max(double.nan, 1)},
        },
      ],
    ),
    'literals': VectorSection(
      'The double a literal or a constant expression of lib/domain '
          'stands for',
      () => [
        for (final e in MathLiterals.values.entries)
          {'text': e.key, 'out': e.value},
      ],
    ),
  };

  static Map<String, Object?> _quotient(double q) => {
    'quotient': q,
    'round': q.isFinite ? q.round() : null,
    'floor': q.isFinite ? q.floor() : null,
    'ceil': q.isFinite ? q.ceil() : null,
  };

  static Map<String, Object?> _clamp(num x, num low, num high) {
    try {
      return {'out': x.clamp(low, high)};
    } on ArgumentError {
      return {'throws': true};
    }
  }

  static bool _throws(double x) {
    var thrown = 0;
    for (final int Function() f in [x.round, x.floor, x.ceil, x.toInt]) {
      try {
        f();
      } on UnsupportedError {
        thrown++;
      }
    }
    return thrown == 4;
  }
}

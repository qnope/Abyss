import 'dart:math';

/// The Dart VM's `Random(seed)`, written again from the SDK's
/// `sdk/lib/_internal/vm/lib/math_patch.dart` with nothing but 64-bit
/// whole numbers that wrap: the specification of the port's `DartRandom`,
/// kept true by the vectors (see `reference/vectors/README.md`).
class DartRandomSpec implements Random {
  static const int _mask32 = 0xFFFFFFFF;
  static const int _pow32 = 4294967296;

  int _state;

  /// The state is the mixed [seed], advanced four times.
  DartRandomSpec(int seed) : _state = mix(seed) {
    for (var i = 0; i < 4; i++) {
      _advance();
    }
  }

  /// Thomas Wang's 64-bit mix; 0 is replaced by `0x5a17`. Every shift
  /// to the right fills with zeros, every sum and product wraps.
  static int mix(int seed) {
    int n = seed;
    n = ~n + (n << 21);
    n = n ^ (n >>> 24);
    n = n * 265;
    n = n ^ (n >>> 14);
    n = n * 21;
    n = n ^ (n >>> 28);
    n = n + (n << 31);
    return n == 0 ? 0x5a17 : n;
  }

  /// Multiply-with-carry in base 2^32: the low half times `0xffffda61`,
  /// plus the high half.
  void _advance() {
    _state = 0xffffda61 * (_state & _mask32) + (_state >>> 32);
  }

  @override
  int nextInt(int max) {
    if (max <= 0 || max > _pow32) throw RangeError.range(max, 1, _pow32);
    if (max & -max == max) {
      _advance();
      return _state & _mask32 & (max - 1);
    }
    int low;
    int result;
    do {
      _advance();
      low = _state & _mask32;
      result = low % max;
    } while (low - result + max > _pow32);
    return result;
  }

  /// 26 bits then 27 bits, the first ones the high bits of 53.
  @override
  double nextDouble() =>
      (nextInt(1 << 26) * 134217728.0 + nextInt(1 << 27)) /
      9007199254740992.0;

  @override
  bool nextBool() => nextInt(2) == 0;
}

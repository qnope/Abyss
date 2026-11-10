/// Seeds and bounds the vectors of `Random` are drawn with.
abstract final class RandomSeeds {
  /// The only seed the VM's mix turns into 0, which it then replaces by
  /// `0x5a17`: the inverse of 2^21 - 1 modulo 2^64.
  static const int mixedToZero = 9223367638806167551;

  /// Small, large, negative, beyond 2^32 and at the edges of 64 bits;
  /// 2^31 - 2 and 2^31 - 1 are the largest the game draws.
  static const List<int> all = <int>[
    0, 1, 2, 3, 7, 42, 100, 255, 256, 1000, 65535, 65536,
    20261110, 123456789, 987654321, 1073741823, 1640531527,
    2147483646, 2147483647, 2147483648, 4294967295, 4294967296,
    4294967297, 8589934592, 1099511640121, 9007199254740992,
    4611686018427387904, 9223372036854775807,
    -1, -2, -42, -2147483648, -4294967296, -9223372036854775808,
    mixedToZero,
  ];

  /// A few of [all] for the costly sections.
  static const List<int> few = <int>[
    0, 1, 42, 123456789, 2147483647, 4294967296, -1,
  ];

  /// Bounds of `nextInt`: the ones the rules use (2 to 101, the cells of
  /// a map, `0x7FFFFFFF`), powers of two and their neighbours up to the
  /// largest allowed, 2^32, and 3 * 2^30, drawn again one time in four.
  static const List<int> bounds = <int>[
    1, 2, 3, 4, 5, 6, 7, 8, 10, 16, 21, 26, 31, 41, 51, 81, 100, 101,
    255, 256, 257, 375, 400, 1000, 65535, 65536, 65537, 1000000,
    1073741823, 1073741824, 1073741825, 2147483647, 2147483648,
    2147483649, 3221225472, 4294967295, 4294967296,
  ];

  /// Bounds `nextInt` refuses.
  static const List<int> refused = <int>[0, -1, 4294967297, -4294967296];
}

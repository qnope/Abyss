/// Every double literal of `lib/domain`, as the Dart compiler reads it,
/// and the constant expressions the rules compare a draw with.
///
/// The port writes the same literals: its compiler must read the same
/// doubles, to the last bit.
abstract final class MathLiterals {
  static const Map<String, double> values = <String, double>{
    '0.04': 0.04,
    '0.05': 0.05,
    '0.06': 0.06,
    '0.08': 0.08,
    '0.1': 0.1,
    '0.12': 0.12,
    '0.125': 0.125,
    '0.15': 0.15,
    '0.2': 0.2,
    '0.225': 0.225,
    '0.25': 0.25,
    '0.3': 0.3,
    '0.5': 0.5,
    '0.50': 0.50,
    '0.60': 0.60,
    '0.625': 0.625,
    '0.65': 0.65,
    '0.7': 0.7,
    '0.75': 0.75,
    '0.8': 0.8,
    '0.80': 0.80,
    '0.85': 0.85,
    '0.9': 0.9,
    '0.90': 0.90,
    '0.95': 0.95,
    '1.0': 1.0,
    '1.1': 1.1,
    '1.2': 1.2,
    '1.6': 1.6,
    '2.0': 2.0,
    // ContentPlacer: where the kept third of a treasure band ends.
    '1 / 3': 1 / 3,
    '0.60 + (0.80 - 0.60) * (1 / 3)': 0.60 + (0.80 - 0.60) * (1 / 3),
    '0.80 + (0.90 - 0.80) * (1 / 3)': 0.80 + (0.90 - 0.80) * (1 / 3),
    // FactionKernelGuard: half the share.
    '0.5 / 2': 0.5 / 2,
    // KernelSiege: the confidences of the factions, eased.
    '0.85 - 0.125': 0.85 - 0.125,
    '0.8 - 0.125': 0.8 - 0.125,
    '0.75 - 0.125': 0.75 - 0.125,
    '0.7 - 0.125': 0.7 - 0.125,
  };
}

import 'consumption_calculator.dart';
import 'unit.dart';
import 'unit_type.dart';

class UnitLossCalculator {
  /// Returns map of unit losses per type when algae is insufficient.
  /// Losses are proportional: each type loses the same percentage,
  /// rounded UP (ceil).
  static Map<UnitType, int> calculateLosses({
    required Map<UnitType, Unit> units,
    required int algaeProduction,
    required int algaeStock,
  }) {
    final totalConsumption = ConsumptionCalculator.totalUnitConsumption(units);
    final available = algaeProduction + algaeStock;

    if (available >= totalConsumption) return {};

    final deficit = totalConsumption - available;
    final lossRatio = deficit / totalConsumption;

    final losses = <UnitType, int>{};
    for (final entry in units.entries) {
      if (entry.value.count <= 0) continue;

      var lost = (entry.value.count * lossRatio).ceil();
      if (lost > entry.value.count) lost = entry.value.count;
      losses[entry.key] = lost;
    }

    return losses;
  }
}

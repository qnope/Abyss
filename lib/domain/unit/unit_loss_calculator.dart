import '../resource/consumption_calculator.dart';
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

  /// Calculates losses across all levels (read-only, for preview).
  static Map<UnitType, int> calculateLossesAllLevels({
    required Map<int, Map<UnitType, Unit>> unitsPerLevel,
    required int algaeProduction,
    required int algaeStock,
  }) {
    final total = ConsumptionCalculator.totalUnitConsumptionAllLevels(
      unitsPerLevel,
    );
    final available = algaeProduction + algaeStock;
    if (available >= total || total == 0) return {};
    final lossRatio = (total - available) / total;
    return _aggregateLosses(unitsPerLevel, lossRatio);
  }

  /// Applies losses across all levels and returns aggregated totals.
  static Map<UnitType, int> applyLossesAllLevels({
    required Map<int, Map<UnitType, Unit>> unitsPerLevel,
    required int algaeProduction,
    required int algaeStock,
  }) {
    final total = ConsumptionCalculator.totalUnitConsumptionAllLevels(
      unitsPerLevel,
    );
    final available = algaeProduction + algaeStock;
    if (available >= total || total == 0) return {};
    final lossRatio = (total - available) / total;
    final losses = <UnitType, int>{};
    for (final units in unitsPerLevel.values) {
      for (final entry in units.entries) {
        if (entry.value.count <= 0) continue;
        var lost = (entry.value.count * lossRatio).ceil();
        if (lost > entry.value.count) lost = entry.value.count;
        entry.value.count -= lost;
        losses[entry.key] = (losses[entry.key] ?? 0) + lost;
      }
    }
    return losses;
  }

  static Map<UnitType, int> _aggregateLosses(
    Map<int, Map<UnitType, Unit>> unitsPerLevel,
    double lossRatio,
  ) {
    final losses = <UnitType, int>{};
    for (final units in unitsPerLevel.values) {
      for (final entry in units.entries) {
        if (entry.value.count <= 0) continue;
        var lost = (entry.value.count * lossRatio).ceil();
        if (lost > entry.value.count) lost = entry.value.count;
        losses[entry.key] = (losses[entry.key] ?? 0) + lost;
      }
    }
    return losses;
  }
}

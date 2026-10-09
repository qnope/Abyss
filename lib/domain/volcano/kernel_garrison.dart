import '../building/building_type.dart';
import '../game/player.dart';
import '../unit/unit.dart';
import '../unit/unit_type.dart';

/// The units shut inside the volcanic kernel to guard it.
///
/// They live in their own stock of `Player.unitsPerLevel`, under
/// [stockKey], so they eat algae like any unit but neither explore nor
/// fight anywhere else. Only they defend the kernel against the waves.
abstract final class KernelGarrison {
  /// Map level of the volcanic kernel.
  static const int volcanoLevel = 3;

  /// Key of the garrison's stock in `Player.unitsPerLevel`: the heart of
  /// the volcano, one step below its map.
  static const int stockKey = 4;

  /// Units of the garrison, by type, empty ones left out.
  static Map<UnitType, int> of(Player player) => <UnitType, int>{
    for (final MapEntry<UnitType, Unit> e
        in player.unitsOnLevel(stockKey).entries)
      if (e.value.count > 0) e.key: e.value.count,
  };

  /// Number of units in the garrison.
  static int sizeOf(Player player) =>
      of(player).values.fold<int>(0, (int a, int b) => a + b);

  /// The garrison's stock, created with every unit type when missing.
  static Map<UnitType, Unit> stockOf(Player player) =>
      stockAt(player, stockKey);

  /// [player]'s stock under [key], created with every unit type when
  /// missing.
  static Map<UnitType, Unit> stockAt(Player player, int key) {
    final Map<UnitType, Unit> stock =
        player.unitsPerLevel.putIfAbsent(key, () => <UnitType, Unit>{});
    for (final UnitType type in UnitType.values) {
      stock.putIfAbsent(type, () => Unit(type: type));
    }
    return stock;
  }

  /// Level of [player]'s volcanic kernel building.
  static int kernelLevelOf(Player player) =>
      player.buildings[BuildingType.volcanicKernel]?.level ?? 0;
}

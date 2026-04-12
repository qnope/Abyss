import '../game/player.dart';
import '../unit/unit.dart';
import '../unit/unit_type.dart';
import 'attack_volcanic_kernel_result.dart';

class AttackVolcanicKernelHelpers {
  const AttackVolcanicKernelHelpers._();

  static AttackVolcanicKernelResult? validateUnits(
    Player player,
    int level,
    Map<UnitType, int> selectedUnits,
  ) {
    if (!selectedUnits.containsKey(UnitType.abyssAdmiral) ||
        selectedUnits[UnitType.abyssAdmiral]! <= 0) {
      return const AttackVolcanicKernelResult.failure(
        'Un Amiral des Abysses est requis',
      );
    }
    final Map<UnitType, Unit> stock = player.unitsOnLevel(level);
    for (final MapEntry<UnitType, int> entry in selectedUnits.entries) {
      if (entry.value <= 0) continue;
      final int available = stock[entry.key]?.count ?? 0;
      if (entry.value > available) {
        return const AttackVolcanicKernelResult.failure(
          'Unités insuffisantes',
        );
      }
    }
    return null;
  }
}

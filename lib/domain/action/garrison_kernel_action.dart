import '../game/game.dart';
import '../game/player.dart';
import '../unit/unit.dart';
import '../unit/unit_type.dart';
import '../volcano/kernel_garrison.dart';
import 'action.dart';
import 'action_result.dart';
import 'action_type.dart';

/// Moves units from the volcano level into the kernel's garrison, or
/// back out when [withdraw] is set.
class GarrisonKernelAction extends Action {
  final Map<UnitType, int> selectedUnits;
  final bool withdraw;

  GarrisonKernelAction({required this.selectedUnits, this.withdraw = false});

  @override
  ActionType get type => ActionType.garrisonKernel;

  @override
  String get description =>
      withdraw ? 'Retirer de la garnison' : 'Mettre en garnison';

  @override
  ActionResult validate(Game game, Player player) {
    if (!game.isVolcanicKernelCapturedBy(player.id)) {
      return const ActionResult.failure('Noyau non capturé');
    }
    int total = 0;
    final Map<UnitType, Unit> from = _from(player);
    for (final MapEntry<UnitType, int> e in selectedUnits.entries) {
      if (e.value <= 0) continue;
      if (e.value > (from[e.key]?.count ?? 0)) {
        return const ActionResult.failure('Unités insuffisantes');
      }
      total += e.value;
    }
    if (total <= 0) {
      return const ActionResult.failure('Aucune unité sélectionnée');
    }
    return const ActionResult.success();
  }

  @override
  ActionResult execute(Game game, Player player) {
    final ActionResult validation = validate(game, player);
    if (!validation.isSuccess) return validation;
    final Map<UnitType, Unit> from = _from(player);
    final Map<UnitType, Unit> to = KernelGarrison.stockAt(
      player,
      withdraw ? KernelGarrison.volcanoLevel : KernelGarrison.stockKey,
    );
    for (final MapEntry<UnitType, int> e in selectedUnits.entries) {
      if (e.value <= 0) continue;
      from[e.key]!.count -= e.value;
      to[e.key]!.count += e.value;
    }
    return const ActionResult.success();
  }

  Map<UnitType, Unit> _from(Player player) => withdraw
      ? player.unitsOnLevel(KernelGarrison.stockKey)
      : player.unitsOnLevel(KernelGarrison.volcanoLevel);
}

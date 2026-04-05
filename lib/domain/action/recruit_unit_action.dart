import 'action.dart';
import 'action_result.dart';
import 'action_type.dart';
import '../building/building_type.dart';
import '../game/game.dart';
import '../unit/unit_cost_calculator.dart';
import '../unit/unit_type.dart';

class RecruitUnitAction extends Action {
  final UnitType unitType;
  final int quantity;

  RecruitUnitAction({required this.unitType, required this.quantity});

  @override
  ActionType get type => ActionType.recruitUnit;

  @override
  String get description => 'Recruter $quantity $unitType';

  @override
  ActionResult validate(Game game) {
    final barracksLevel =
        game.buildings[BuildingType.barracks]?.level ?? 0;

    if (!UnitCostCalculator().isUnlocked(unitType, barracksLevel)) {
      return ActionResult.failure('Unite verrouilee');
    }
    if (game.recruitedUnitTypes.contains(unitType)) {
      return ActionResult.failure('Recrutement deja effectue ce tour');
    }
    if (quantity <= 0) {
      return ActionResult.failure('Quantite invalide');
    }

    final costs = UnitCostCalculator().recruitmentCost(unitType);
    for (final entry in costs.entries) {
      final totalCost = entry.value * quantity;
      if (game.resources[entry.key]!.amount < totalCost) {
        return ActionResult.failure('Ressources insuffisantes');
      }
    }

    return ActionResult.success();
  }

  @override
  ActionResult execute(Game game) {
    final validation = validate(game);
    if (!validation.isSuccess) return validation;

    final costs = UnitCostCalculator().recruitmentCost(unitType);
    for (final entry in costs.entries) {
      game.resources[entry.key]!.amount -= entry.value * quantity;
    }
    game.units[unitType]!.count += quantity;
    game.recruitedUnitTypes.add(unitType);

    return ActionResult.success();
  }
}

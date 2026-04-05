import 'package:flutter/material.dart';
import '../../../domain/action/action_executor.dart';
import '../../../domain/building/building.dart';
import '../../../domain/building/building_type.dart';
import '../../../domain/game/game.dart';
import '../../../domain/action/recruit_unit_action.dart';
import '../../../domain/unit/unit_cost_calculator.dart';
import '../../../domain/unit/unit_type.dart';
import '../../../domain/action/upgrade_building_action.dart';
import '../../widgets/building/building_detail_sheet.dart';
import '../../widgets/unit/unit_detail_sheet.dart';

void showBuildingDetailAction(
  BuildContext context,
  Game game,
  Building building,
  VoidCallback onChanged,
) {
  showBuildingDetailSheet(
    context,
    building: building,
    resources: game.resources,
    allBuildings: game.buildings,
    onUpgrade: () {
      final action = UpgradeBuildingAction(buildingType: building.type);
      final result = ActionExecutor().execute(action, game);
      if (result.isSuccess) {
        onChanged();
        Navigator.pop(context);
      }
    },
  );
}

void showUnitDetailAction(
  BuildContext context,
  Game game,
  UnitType unitType,
  VoidCallback onChanged,
) {
  final calculator = UnitCostCalculator();
  final barracksLevel = game.buildings[BuildingType.barracks]!.level;
  final isUnlocked = calculator.isUnlocked(unitType, barracksLevel);
  final count = game.units[unitType]?.count ?? 0;
  final hasRecruitedThisType = game.recruitedUnitTypes.contains(unitType);
  showUnitDetailSheet(
    context,
    unitType: unitType,
    count: count,
    isUnlocked: isUnlocked,
    barracksLevel: barracksLevel,
    resources: game.resources,
    hasRecruitedThisType: hasRecruitedThisType,
    onRecruit: (quantity) {
      final action = RecruitUnitAction(unitType: unitType, quantity: quantity);
      final result = ActionExecutor().execute(action, game);
      if (result.isSuccess) {
        onChanged();
        Navigator.pop(context);
      }
    },
  );
}

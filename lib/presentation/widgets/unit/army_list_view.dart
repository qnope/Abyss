import 'package:flutter/material.dart';
import '../../../domain/building/building.dart';
import '../../../domain/building/building_type.dart';
import '../../../domain/unit/unit.dart';
import '../../../domain/unit/unit_cost_calculator.dart';
import '../../../domain/unit/unit_type.dart';
import '../building/base_shield_badge.dart';
import 'unit_card.dart';

class ArmyListView extends StatelessWidget {
  final Map<int, Map<UnitType, Unit>> unitsPerLevel;
  final int barracksLevel;
  final Map<BuildingType, Building> buildings;
  final void Function(UnitType unitType) onUnitTap;

  const ArmyListView({
    super.key,
    required this.unitsPerLevel,
    required this.barracksLevel,
    required this.buildings,
    required this.onUnitTap,
  });

  Map<int, int> _countsFor(UnitType type) {
    final result = <int, int>{};
    for (final entry in unitsPerLevel.entries) {
      final count = entry.value[type]?.count ?? 0;
      if (count > 0) result[entry.key] = count;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BaseShieldBadge(buildings: buildings),
        Expanded(
          child: ListView.builder(
            itemCount: UnitType.values.length,
            itemBuilder: (context, index) {
              final unitType = UnitType.values[index];
              final countsPerLevel = _countsFor(unitType);
              final isUnlocked = UnitCostCalculator().isUnlocked(
                unitType,
                barracksLevel,
              );
              return Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: index == 0 ? 16 : 4,
                  bottom: 4,
                ),
                child: UnitCard(
                  unitType: unitType,
                  countsPerLevel: countsPerLevel,
                  isUnlocked: isUnlocked,
                  onTap: () => onUnitTap(unitType),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

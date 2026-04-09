import 'package:flutter/material.dart';
import '../../../domain/building/building.dart';
import '../../../domain/building/building_type.dart';
import '../../../domain/unit/unit.dart';
import '../../../domain/unit/unit_cost_calculator.dart';
import '../../../domain/unit/unit_type.dart';
import '../building/base_shield_badge.dart';
import 'unit_card.dart';

class ArmyListView extends StatelessWidget {
  final Map<UnitType, Unit> units;
  final int barracksLevel;
  final Map<BuildingType, Building> buildings;
  final void Function(UnitType unitType) onUnitTap;

  const ArmyListView({
    super.key,
    required this.units,
    required this.barracksLevel,
    required this.buildings,
    required this.onUnitTap,
  });

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
              final count = units[unitType]?.count ?? 0;
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
                  count: count,
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

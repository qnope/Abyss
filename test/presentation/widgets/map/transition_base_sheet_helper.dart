import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/fight/assault/assault_plan.dart';
import 'package:abyss/domain/map/transition_base.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/widgets/map/transition_base_sheet.dart';

/// A button that opens the sheet of [base] when tapped ([openSheet]).
Widget buildSheetOpener({
  required TransitionBase base,
  bool hasBuildingRequirement = true,
  BuildingType requiredBuilding = BuildingType.descentModule,
  Map<UnitType, int> unitsOnTarget = const {},
  VoidCallback? onAttack,
  VoidCallback? onDescend,
  AssaultPlan? assaultPlan,
}) {
  return MaterialApp(
    home: Scaffold(
      body: Builder(
        builder: (ctx) => ElevatedButton(
          onPressed: () => showTransitionBaseSheet(ctx,
              transitionBase: base,
              level: 1,
              hasBuildingRequirement: hasBuildingRequirement,
              requiredBuilding: requiredBuilding,
              unitsOnTarget: unitsOnTarget,
              onAttack: onAttack,
              onDescend: onDescend,
              assaultPlan: assaultPlan),
          child: const Text('Open'),
        ),
      ),
    ),
  );
}

Future<void> openSheet(WidgetTester t) async {
  await t.tap(find.text('Open'));
  await t.pumpAndSettle();
}

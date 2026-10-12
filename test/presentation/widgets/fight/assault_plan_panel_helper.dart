import 'package:abyss/domain/fight/assault/assault_plan.dart';
import 'package:abyss/domain/fight/assault/assault_target.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/widgets/fight/assault_check_row.dart';
import 'package:abyss/presentation/widgets/fight/assault_plan_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../domain/fight/assault/assault_test_helper.dart';

// What the tests of the AssaultPlanPanel share.

const admiral = UnitType.abyssAdmiral;
const guardian = UnitType.guardian;
const harpoonist = UnitType.harpoonist;

AssaultPlan plan(
  Map<UnitType, int> army, {
  AssaultTarget target = AssaultTarget.faille,
  Map<UnitType, int>? stock,
  int hq = 4,
  int maxHarpoonists = AssaultPlan.defaultMaxHarpoonists,
}) =>
    AssaultPlan.of(
      player: assaultPlayer(stock: stock ?? army, hq: hq),
      level: 1,
      target: target,
      army: army,
      maxHarpoonists: maxHarpoonists,
    );

Future<void> pump(WidgetTester tester, AssaultPlan plan) =>
    tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: AssaultPlanPanel(plan: plan, level: 1),
        ),
      ),
    ));

AssaultCheckState stateOf(WidgetTester tester, String title) => tester
    .widget<AssaultCheckRow>(find.widgetWithText(AssaultCheckRow, title))
    .state;

const strong = {admiral: 1, guardian: 4, harpoonist: 10};


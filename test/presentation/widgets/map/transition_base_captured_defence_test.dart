import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/faction/post_defence.dart';
import 'package:abyss/domain/map/transition_base.dart';
import 'package:abyss/domain/map/transition_base_type.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/widgets/map/post_defence_panel.dart';
import 'package:abyss/presentation/widgets/map/transition_base_captured_section.dart';
import 'package:abyss/presentation/widgets/unit/unit_count_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/localized_app.dart';

Future<void> _pump(WidgetTester t, {PostDefence? defence}) => t.pumpWidget(
  localizedApp(
    Scaffold(
      body: TransitionBaseCapturedSection(
        transitionBase: TransitionBase(
          type: TransitionBaseType.faille,
          name: 'F',
          capturedBy: 'p1',
        ),
        hasBuildingRequirement: true,
        requiredBuilding: BuildingType.descentModule,
        unitsOnTarget: const {UnitType.harpoonist: 4},
        defence: defence,
        onDescend: () {},
      ),
    ),
  ),
);

void main() {
  testWidgets('shows the defence of the post under its defenders', (t) async {
    await _pump(
      t,
      defence: const PostDefence(
        threat: null,
        passage: BuildingType.descentModule,
        unitsBelow: 4,
        reinforcements: 0,
      ),
    );

    expect(find.byType(PostDefencePanel), findsOneWidget);
    final panelTop = t.getTopLeft(find.byType(PostDefencePanel)).dy;
    final unitsBottom = t.getBottomLeft(find.byType(UnitCountPanel)).dy;
    expect(panelTop, greaterThan(unitsBottom));
    expect(find.text('Envoyer des unités au Niveau 2'), findsOneWidget);
  });

  testWidgets('shows no defence block without one', (t) async {
    await _pump(t);

    expect(find.byType(PostDefencePanel), findsNothing);
    expect(find.byType(UnitCountPanel), findsOneWidget);
  });
}

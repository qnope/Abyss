import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/map/transition_base.dart';
import 'package:abyss/domain/map/transition_base_type.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/l10n/abyss_locale.dart';
import 'package:abyss/presentation/widgets/map/transition_base_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/sheet_opener.dart';

void Function(BuildContext) _sheet(
  TransitionBase base, {
  bool hasBuilding = true,
  Map<UnitType, int> units = const {},
}) =>
    (context) => showTransitionBaseSheet(
          context,
          transitionBase: base,
          level: 1,
          hasBuildingRequirement: hasBuilding,
          requiredBuilding: BuildingType.pressureCapsule,
          unitsOnTarget: units,
          onAttack: () {},
          onDescend: () {},
        );

void main() {
  testWidgets('uncaptured base in English', (t) async {
    final base = TransitionBase(type: TransitionBaseType.faille, name: 'F1');
    await openSheet(t, AbyssLocale.en, _sheet(base));
    expect(find.text('Difficulty'), findsOneWidget);
    expect(find.text('Income once captured'), findsOneWidget);
    expect(find.text('+2 pearls per turn'), findsOneWidget);
    expect(find.text('Neutral — Guardians present'), findsOneWidget);
    expect(find.text('Assault'), findsOneWidget);
  });

  testWidgets('captured empty base in English', (t) async {
    final base = TransitionBase(
        type: TransitionBaseType.faille, name: 'F1', capturedBy: 'p1');
    await openSheet(t, AbyssLocale.en, _sheet(base));
    expect(find.text('Defenders on Level 2'), findsOneWidget);
    expect(find.textContaining('No units.'), findsOneWidget);
  });

  testWidgets('captured base in Spanish', (t) async {
    final base = TransitionBase(
        type: TransitionBaseType.cheminee, name: 'C1', capturedBy: 'p1');
    await openSheet(
        t, AbyssLocale.es, _sheet(base, hasBuilding: false, units: {UnitType.scout: 1}));
    expect(find.text('Capturada'), findsOneWidget);
    expect(find.text('+3 perlas por turno'), findsOneWidget);
    expect(find.text('Defensores en el Nivel 3'), findsOneWidget);
    expect(
      find.text('Edificio necesario para enviar unidades: '
          'Cápsula Presurizada'),
      findsOneWidget,
    );
    expect(find.text('Enviar unidades al Nivel 3'), findsOneWidget);
  });
}

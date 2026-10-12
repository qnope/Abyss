import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/map/transition_base.dart';
import 'package:abyss/domain/map/transition_base_type.dart';
import 'package:abyss/domain/unit/unit_type.dart';

import 'transition_base_sheet_helper.dart';

void main() {
  group('Captured', () {
    testWidgets('shows captured status and send button', (t) async {
      final base = TransitionBase(
          type: TransitionBaseType.faille,
          name: 'F1',
          capturedBy: 'p1');
      await t.pumpWidget(buildSheetOpener(
          base: base, onDescend: () {}));
      await openSheet(t);
      expect(find.text('Capturée'), findsOneWidget);
      expect(find.text('Envoyer des unités au Niveau 2'),
          findsOneWidget);
    });

    testWidgets('descend callback fires', (t) async {
      var called = false;
      final base = TransitionBase(
          type: TransitionBaseType.faille,
          name: 'F1',
          capturedBy: 'p1');
      await t.pumpWidget(buildSheetOpener(
          base: base, onDescend: () => called = true));
      await openSheet(t);
      await t.tap(find.text('Envoyer des unités au Niveau 2'));
      await t.pumpAndSettle();
      expect(called, isTrue);
    });

    testWidgets('button disabled when building missing', (t) async {
      final base = TransitionBase(
          type: TransitionBaseType.faille,
          name: 'F1',
          capturedBy: 'p1');
      await t.pumpWidget(buildSheetOpener(
          base: base,
          hasBuildingRequirement: false,
          onDescend: () {}));
      await openSheet(t);
      final btn = t.widget<FilledButton>(find.widgetWithText(
          FilledButton, 'Envoyer des unités au Niveau 2'));
      expect(btn.onPressed, isNull);
      expect(
        find.text(
          'Bâtiment requis pour envoyer des unités : Module de Descente',
        ),
        findsOneWidget,
      );
    });

    testWidgets('lists the defenders by type when units present', (t) async {
      final base = TransitionBase(
          type: TransitionBaseType.faille,
          name: 'F1',
          capturedBy: 'p1');
      await t.pumpWidget(buildSheetOpener(
          base: base,
          unitsOnTarget: {UnitType.harpoonist: 12, UnitType.guardian: 3},
          onDescend: () {}));
      await openSheet(t);
      expect(find.text('Défenseurs au Niveau 2'), findsOneWidget);
      expect(find.text('15'), findsOneWidget);
      expect(find.text('Harponneur'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
      expect(find.text('Gardien'), findsOneWidget);
    });

    testWidgets('warns when nobody defends the post', (t) async {
      final base = TransitionBase(
          type: TransitionBaseType.faille,
          name: 'F1',
          capturedBy: 'p1');
      await t.pumpWidget(buildSheetOpener(base: base, onDescend: () {}));
      await openSheet(t);
      expect(find.text('Défenseurs au Niveau 2'), findsOneWidget);
      expect(find.textContaining('Aucune unité.'), findsOneWidget);
    });

    testWidgets('a captured cheminee counts the units of level 3', (t) async {
      final base = TransitionBase(
          type: TransitionBaseType.cheminee,
          name: 'C1',
          capturedBy: 'p1');
      await t.pumpWidget(buildSheetOpener(
          base: base,
          requiredBuilding: BuildingType.pressureCapsule,
          unitsOnTarget: {UnitType.scout: 4},
          onDescend: () {}));
      await openSheet(t);
      expect(find.text('Défenseurs au Niveau 3'), findsOneWidget);
      expect(find.text('Éclaireur'), findsOneWidget);
    });

    testWidgets('an uncaptured base shows no defenders', (t) async {
      final base = TransitionBase(
          type: TransitionBaseType.faille, name: 'F1');
      await t.pumpWidget(buildSheetOpener(base: base));
      await openSheet(t);
      expect(find.textContaining('Défenseurs'), findsNothing);
    });
  });
}

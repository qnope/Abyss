import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/fight/assault/assault_plan.dart';
import 'package:abyss/domain/fight/assault/assault_target.dart';
import 'package:abyss/domain/map/transition_base.dart';
import 'package:abyss/domain/map/transition_base_type.dart';
import 'package:abyss/domain/unit/unit_type.dart';

import '../../../domain/fight/assault/assault_test_helper.dart';
import 'transition_base_sheet_helper.dart';

void main() {
  group('Uncaptured faille', () {
    testWidgets('shows name, type, difficulty and status', (t) async {
      final base = TransitionBase(
          type: TransitionBaseType.faille, name: 'Faille Alpha');
      await t.pumpWidget(buildSheetOpener(base: base));
      await openSheet(t);
      expect(find.text('Faille Alpha'), findsOneWidget);
      expect(find.text('Faille Abyssale'), findsOneWidget);
      expect(find.text('4/5'), findsOneWidget);
      expect(find.text('Neutre \u2014 Gardiens présents'),
          findsOneWidget);
    });

    testWidgets('assault enabled when callback provided', (t) async {
      var called = false;
      final base = TransitionBase(
          type: TransitionBaseType.faille, name: 'F1');
      await t.pumpWidget(buildSheetOpener(
          base: base, onAttack: () => called = true));
      await openSheet(t);
      final btn = t.widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Assaut'));
      expect(btn.onPressed, isNotNull);
      await t.tap(find.text('Assaut'));
      await t.pumpAndSettle();
      expect(called, isTrue);
    });

    testWidgets('shows the assault plan above the assault button',
        (t) async {
      final base = TransitionBase(
          type: TransitionBaseType.faille, name: 'F1');
      await t.pumpWidget(buildSheetOpener(
        base: base,
        assaultPlan: AssaultPlan.of(
          player: assaultPlayer(stock: {UnitType.abyssAdmiral: 1}),
          level: 1,
          target: AssaultTarget.faille,
          army: {UnitType.abyssAdmiral: 1},
        ),
      ));
      await openSheet(t);
      expect(find.text("PLAN D'ASSAUT"), findsOneWidget);
      expect(find.text('1 Amiral au niveau 1'), findsOneWidget);
      expect(find.text('Assaut'), findsOneWidget);
    });

    testWidgets('shows no plan without one', (t) async {
      final base = TransitionBase(
          type: TransitionBaseType.faille, name: 'F1');
      await t.pumpWidget(buildSheetOpener(base: base));
      await openSheet(t);
      expect(find.text("PLAN D'ASSAUT"), findsNothing);
    });

    testWidgets('assault disabled when no callback', (t) async {
      final base = TransitionBase(
          type: TransitionBaseType.faille, name: 'F1');
      await t.pumpWidget(buildSheetOpener(base: base));
      await openSheet(t);
      final btn = t.widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Assaut'));
      expect(btn.onPressed, isNull);
    });
  });

  group('Uncaptured cheminee', () {
    testWidgets('shows cheminee type and difficulty', (t) async {
      final base = TransitionBase(
          type: TransitionBaseType.cheminee, name: 'Cheminee Beta');
      await t.pumpWidget(buildSheetOpener(base: base));
      await openSheet(t);
      expect(find.text('5/5'), findsOneWidget);
      expect(find.text('Cheminée du Noyau'), findsOneWidget);
    });
  });
}

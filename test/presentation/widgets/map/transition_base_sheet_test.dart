import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/map/transition_base.dart';
import 'package:abyss/domain/map/transition_base_type.dart';
import 'package:abyss/presentation/widgets/map/transition_base_sheet.dart';

Widget _buildOpener({
  required TransitionBase base,
  bool hasBuildingRequirement = true,
  String requiredBuildingName = 'le Module de Descente',
  int unitCountOnTarget = 0,
  VoidCallback? onAttack,
  VoidCallback? onDescend,
}) {
  return MaterialApp(
    home: Scaffold(
      body: Builder(
        builder: (ctx) => ElevatedButton(
          onPressed: () => showTransitionBaseSheet(ctx,
              transitionBase: base,
              level: 1,
              hasBuildingRequirement: hasBuildingRequirement,
              requiredBuildingName: requiredBuildingName,
              unitCountOnTarget: unitCountOnTarget,
              onAttack: onAttack,
              onDescend: onDescend),
          child: const Text('Open'),
        ),
      ),
    ),
  );
}

Future<void> _open(WidgetTester t) async {
  await t.tap(find.text('Open'));
  await t.pumpAndSettle();
}

void main() {
  group('Uncaptured faille', () {
    testWidgets('shows name, type, difficulty and status', (t) async {
      final base = TransitionBase(
          type: TransitionBaseType.faille, name: 'Faille Alpha');
      await t.pumpWidget(_buildOpener(base: base));
      await _open(t);
      expect(find.text('Faille Alpha'), findsOneWidget);
      expect(find.text('Faille Abyssale'), findsOneWidget);
      expect(find.text('4/5'), findsOneWidget);
      expect(find.text('Neutre \u2014 Gardiens presents'),
          findsOneWidget);
    });

    testWidgets('assault enabled when callback provided', (t) async {
      var called = false;
      final base = TransitionBase(
          type: TransitionBaseType.faille, name: 'F1');
      await t.pumpWidget(_buildOpener(
          base: base, onAttack: () => called = true));
      await _open(t);
      final btn = t.widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Assaut'));
      expect(btn.onPressed, isNotNull);
      await t.tap(find.text('Assaut'));
      await t.pumpAndSettle();
      expect(called, isTrue);
    });

    testWidgets('assault disabled when no callback', (t) async {
      final base = TransitionBase(
          type: TransitionBaseType.faille, name: 'F1');
      await t.pumpWidget(_buildOpener(base: base));
      await _open(t);
      final btn = t.widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Assaut'));
      expect(btn.onPressed, isNull);
    });
  });

  group('Uncaptured cheminee', () {
    testWidgets('shows cheminee type and difficulty', (t) async {
      final base = TransitionBase(
          type: TransitionBaseType.cheminee, name: 'Cheminee Beta');
      await t.pumpWidget(_buildOpener(base: base));
      await _open(t);
      expect(find.text('5/5'), findsOneWidget);
      expect(find.text('Cheminee du Noyau'), findsOneWidget);
    });
  });

  group('Captured', () {
    testWidgets('shows captured status and send button', (t) async {
      final base = TransitionBase(
          type: TransitionBaseType.faille,
          name: 'F1',
          capturedBy: 'p1');
      await t.pumpWidget(_buildOpener(
          base: base, onDescend: () {}));
      await _open(t);
      expect(find.text('Capturee'), findsOneWidget);
      expect(find.text('Envoyer des unites au Niveau 2'),
          findsOneWidget);
    });

    testWidgets('descend callback fires', (t) async {
      var called = false;
      final base = TransitionBase(
          type: TransitionBaseType.faille,
          name: 'F1',
          capturedBy: 'p1');
      await t.pumpWidget(_buildOpener(
          base: base, onDescend: () => called = true));
      await _open(t);
      await t.tap(find.text('Envoyer des unites au Niveau 2'));
      await t.pumpAndSettle();
      expect(called, isTrue);
    });

    testWidgets('button disabled when building missing', (t) async {
      final base = TransitionBase(
          type: TransitionBaseType.faille,
          name: 'F1',
          capturedBy: 'p1');
      await t.pumpWidget(_buildOpener(
          base: base,
          hasBuildingRequirement: false,
          onDescend: () {}));
      await _open(t);
      final btn = t.widget<FilledButton>(find.widgetWithText(
          FilledButton, 'Envoyer des unites au Niveau 2'));
      expect(btn.onPressed, isNull);
      expect(
        find.textContaining('Construisez'),
        findsOneWidget,
      );
    });

    testWidgets('shows unit count when units present', (t) async {
      final base = TransitionBase(
          type: TransitionBaseType.faille,
          name: 'F1',
          capturedBy: 'p1');
      await t.pumpWidget(_buildOpener(
          base: base,
          unitCountOnTarget: 15,
          onDescend: () {}));
      await _open(t);
      expect(find.text('15 unites au Niveau 2'), findsOneWidget);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/map/transition_base.dart';
import 'package:abyss/domain/map/transition_base_type.dart';
import 'package:abyss/presentation/widgets/map/transition_base_sheet.dart';
Player _player({int descentModule = 0, int pressureCapsule = 0}) {
  final p = Player(name: 'Test');
  p.buildings[BuildingType.descentModule]!.level = descentModule;
  p.buildings[BuildingType.pressureCapsule]!.level = pressureCapsule;
  return p;
}

Widget _buildOpener({
  required TransitionBase base,
  required Player player,
  VoidCallback? onAttack,
  VoidCallback? onDescend,
  VoidCallback? onReinforce,
}) {
  return MaterialApp(
    home: Scaffold(
      body: Builder(
        builder: (ctx) => ElevatedButton(
          onPressed: () => showTransitionBaseSheet(ctx,
              transitionBase: base,
              level: 1,
              player: player,
              onAttack: onAttack,
              onDescend: onDescend,
              onReinforce: onReinforce),
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
      await t.pumpWidget(
          _buildOpener(base: base, player: _player()));
      await _open(t);
      expect(find.text('Faille Alpha'), findsOneWidget);
      expect(find.text('Faille Abyssale'), findsOneWidget);
      expect(find.text('4/5'), findsOneWidget);
      expect(find.text('Neutre \u2014 Gardiens presents'),
          findsOneWidget);
    });

    testWidgets('assault disabled without prerequisite', (t) async {
      final base = TransitionBase(
          type: TransitionBaseType.faille, name: 'F1');
      await t.pumpWidget(_buildOpener(
          base: base, player: _player(), onAttack: () {}));
      await _open(t);
      expect(find.text('Module de Descente construit'), findsOneWidget);
      final btn = t.widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Assaut'));
      expect(btn.onPressed, isNull);
    });

    testWidgets('assault enabled with prerequisite', (t) async {
      var called = false;
      final base = TransitionBase(
          type: TransitionBaseType.faille, name: 'F1');
      await t.pumpWidget(_buildOpener(
          base: base,
          player: _player(descentModule: 1),
          onAttack: () => called = true));
      await _open(t);
      final btn = t.widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Assaut'));
      expect(btn.onPressed, isNotNull);
      await t.tap(find.text('Assaut'));
      await t.pumpAndSettle();
      expect(called, isTrue);
    });
  });

  group('Uncaptured cheminee', () {
    testWidgets('shows cheminee prerequisite and difficulty', (t) async {
      final base = TransitionBase(
          type: TransitionBaseType.cheminee, name: 'Cheminee Beta');
      await t.pumpWidget(
          _buildOpener(base: base, player: _player()));
      await _open(t);
      expect(find.text('5/5'), findsOneWidget);
      expect(find.text('Cheminee du Noyau'), findsOneWidget);
      expect(find.text('Capsule Pressurisee construite'),
          findsOneWidget);
    });
  });

  group('Captured', () {
    testWidgets('shows captured status and descend button', (t) async {
      final base = TransitionBase(
          type: TransitionBaseType.faille,
          name: 'F1',
          capturedBy: 'p1');
      await t.pumpWidget(_buildOpener(
          base: base, player: _player(), onDescend: () {}));
      await _open(t);
      expect(find.text('Capturee'), findsOneWidget);
      expect(find.text('Descendre au Niveau 2'), findsOneWidget);
    });

    testWidgets('descend callback fires', (t) async {
      var called = false;
      final base = TransitionBase(
          type: TransitionBaseType.faille,
          name: 'F1',
          capturedBy: 'p1');
      await t.pumpWidget(_buildOpener(
          base: base,
          player: _player(),
          onDescend: () => called = true));
      await _open(t);
      await t.tap(find.text('Descendre au Niveau 2'));
      await t.pumpAndSettle();
      expect(called, isTrue);
    });

    testWidgets('reinforce button visible when callback set', (t) async {
      var called = false;
      final base = TransitionBase(
          type: TransitionBaseType.cheminee,
          name: 'C1',
          capturedBy: 'p1');
      await t.pumpWidget(_buildOpener(
          base: base,
          player: _player(),
          onReinforce: () => called = true));
      await _open(t);
      expect(find.text('Envoyer des renforts'), findsOneWidget);
      await t.tap(find.text('Envoyer des renforts'));
      await t.pumpAndSettle();
      expect(called, isTrue);
    });
  });
}

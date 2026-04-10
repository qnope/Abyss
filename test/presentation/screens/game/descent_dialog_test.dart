import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/unit/unit.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/screens/game/descent_dialog.dart';

import '../../../helpers/test_svg_helper.dart';

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  Map<UnitType, Unit> makeUnits({int scouts = 3, int harpoonists = 2}) {
    return {
      if (scouts > 0) UnitType.scout: Unit(type: UnitType.scout, count: scouts),
      if (harpoonists > 0)
        UnitType.harpoonist:
            Unit(type: UnitType.harpoonist, count: harpoonists),
    };
  }

  Widget buildApp({
    Map<UnitType, Unit>? units,
    int targetLevel = 2,
    String baseName = 'Base Alpha',
    void Function(Map<UnitType, int>)? onConfirm,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (ctx) => ElevatedButton(
            onPressed: () => showDialog<void>(
              context: ctx,
              builder: (_) => DescentDialog(
                availableUnits: units ?? makeUnits(),
                targetLevel: targetLevel,
                transitionBaseName: baseName,
                onConfirm: onConfirm ?? (_) {},
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
  }

  Future<void> openDialog(WidgetTester tester, {Widget? app}) async {
    await tester.pumpWidget(app ?? buildApp());
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  group('DescentDialog', () {
    testWidgets('shows header with target level and base name',
        (tester) async {
      await openDialog(tester,
          app: buildApp(targetLevel: 3, baseName: 'Base Omega'));
      expect(find.text('Descente vers Niveau 3'), findsOneWidget);
      expect(find.text('Base Omega'), findsOneWidget);
    });

    testWidgets('displays warning banner', (tester) async {
      await openDialog(tester);
      expect(
        find.textContaining('la descente est definitive'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.warning_amber), findsOneWidget);
    });

    testWidgets('confirm button disabled when 0 selected', (tester) async {
      await openDialog(tester);
      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Descendre (0 unites)'),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('confirm button enabled after selecting units',
        (tester) async {
      await openDialog(tester);
      await tester.tap(find.byIcon(Icons.add).first);
      await tester.pump();

      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Descendre (1 unites)'),
      );
      expect(button.onPressed, isNotNull);
    });

    testWidgets('calls onConfirm with selected units', (tester) async {
      Map<UnitType, int>? result;
      await openDialog(
        tester,
        app: buildApp(onConfirm: (units) => result = units),
      );

      await tester.tap(find.byIcon(Icons.add).first);
      await tester.pump();
      await tester.tap(
        find.widgetWithText(ElevatedButton, 'Descendre (1 unites)'),
      );
      await tester.pumpAndSettle();

      expect(result, isNotNull);
      expect(result!.values.fold<int>(0, (s, v) => s + v), 1);
    });

    testWidgets('Annuler closes dialog without calling onConfirm',
        (tester) async {
      bool called = false;
      await openDialog(
        tester,
        app: buildApp(onConfirm: (_) => called = true),
      );

      await tester.tap(find.widgetWithText(TextButton, 'Annuler'));
      await tester.pumpAndSettle();

      expect(called, isFalse);
      expect(find.byType(DescentDialog), findsNothing);
    });

    testWidgets('hides unit types with 0 count', (tester) async {
      await openDialog(
        tester,
        app: buildApp(units: makeUnits(scouts: 2, harpoonists: 0)),
      );
      expect(find.text('Eclaireur'), findsOneWidget);
      expect(find.text('Harponneur'), findsNothing);
    });
  });
}

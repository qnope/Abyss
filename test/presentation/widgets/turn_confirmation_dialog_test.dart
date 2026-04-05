import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/building_type.dart';
import 'package:abyss/domain/resource_type.dart';
import 'package:abyss/domain/unit_type.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/turn_confirmation_dialog.dart';
import '../../helpers/test_svg_helper.dart';

Widget _app({
  int currentTurn = 3,
  Map<ResourceType, int> production = const {},
  Map<ResourceType, int> consumption = const {},
  List<BuildingType> buildingsToDeactivate = const [],
  Map<UnitType, int> unitsToLose = const {},
}) {
  return MaterialApp(
    theme: AbyssTheme.create(),
    home: Scaffold(
      body: Builder(
        builder: (ctx) => ElevatedButton(
          onPressed: () async {
            await showTurnConfirmationDialog(
              ctx,
              currentTurn: currentTurn,
              production: production,
              consumption: consumption,
              buildingsToDeactivate: buildingsToDeactivate,
              unitsToLose: unitsToLose,
            );
          },
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
  group('TurnConfirmationDialog', () {
    setUp(() => mockSvgAssets());
    tearDown(clearSvgMocks);

    testWidgets('shows turn transition title', (t) async {
      await t.pumpWidget(_app());
      await _open(t);
      expect(find.text('Tour 3 \u2192 Tour 4'), findsOneWidget);
    });

    testWidgets('shows production for each resource', (t) async {
      await t.pumpWidget(
        _app(production: {ResourceType.algae: 5, ResourceType.coral: 8}),
      );
      await _open(t);
      expect(find.text('+5'), findsOneWidget);
      expect(find.text('+8'), findsOneWidget);
      expect(find.text('Algues'), findsOneWidget);
      expect(find.text('Corail'), findsOneWidget);
    });

    testWidgets('no production shows empty message', (t) async {
      await t.pumpWidget(_app());
      await _open(t);
      expect(find.text('Aucune production ce tour.'), findsOneWidget);
    });

    testWidgets('cancel closes dialog', (t) async {
      await t.pumpWidget(_app());
      await _open(t);
      await t.tap(find.text('Annuler'));
      await t.pumpAndSettle();
      expect(find.text('Tour 3 \u2192 Tour 4'), findsNothing);
    });

    testWidgets('confirm closes dialog', (t) async {
      await t.pumpWidget(_app());
      await _open(t);
      await t.tap(find.text('Confirmer'));
      await t.pumpAndSettle();
      expect(find.text('Tour 3 \u2192 Tour 4'), findsNothing);
    });
  });

  group('consumption warnings', () {
    setUp(() => mockSvgAssets());
    tearDown(clearSvgMocks);

    testWidgets('shows building deactivation warning', (t) async {
      await t.pumpWidget(_app(
        production: {ResourceType.algae: 5},
        buildingsToDeactivate: [BuildingType.oreExtractor],
      ));
      await _open(t);
      expect(find.text('Batiments desactives'), findsOneWidget);
      expect(find.text('Extracteur de minerai'), findsOneWidget);
    });

    testWidgets('shows unit loss warning', (t) async {
      await t.pumpWidget(_app(
        production: {ResourceType.algae: 5},
        unitsToLose: {UnitType.scout: 5},
      ));
      await _open(t);
      expect(find.text('Unites perdues'), findsOneWidget);
      expect(find.text('Eclaireur: -5'), findsOneWidget);
    });

    testWidgets('no warnings when no deficits', (t) async {
      await t.pumpWidget(_app(production: {ResourceType.algae: 5}));
      await _open(t);
      expect(find.text('Batiments desactives'), findsNothing);
      expect(find.text('Unites perdues'), findsNothing);
    });

    testWidgets('existing production display still works', (t) async {
      await t.pumpWidget(_app(production: {ResourceType.algae: 50}));
      await _open(t);
      expect(find.text('+50'), findsOneWidget);
    });
  });
}

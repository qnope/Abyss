import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/resource.dart';
import 'package:abyss/domain/resource_type.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/turn_confirmation_dialog.dart';
import '../../helpers/test_svg_helper.dart';

Map<ResourceType, Resource> _resources({
  int algae = 100,
  int maxStorage = 5000,
}) => {
  ResourceType.algae: Resource(
    type: ResourceType.algae, amount: algae, maxStorage: maxStorage,
  ),
  ResourceType.coral: Resource(
    type: ResourceType.coral, amount: 80, maxStorage: 5000,
  ),
  ResourceType.ore: Resource(
    type: ResourceType.ore, amount: 50, maxStorage: 5000,
  ),
  ResourceType.energy: Resource(
    type: ResourceType.energy, amount: 60, maxStorage: 1000,
  ),
  ResourceType.pearl: Resource(
    type: ResourceType.pearl, amount: 5, maxStorage: 100,
  ),
};

Widget _app({
  int currentTurn = 3,
  Map<ResourceType, Resource>? resources,
  Map<ResourceType, int> netProduction = const {},
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
              resources: resources ?? _resources(),
              netProduction: netProduction,
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

    testWidgets('shows resource progression', (t) async {
      await t.pumpWidget(_app(netProduction: {ResourceType.algae: 50}));
      await _open(t);
      expect(find.text('100 (+50) \u2192 150'), findsOneWidget);
    });

    testWidgets('shows capping indicator', (t) async {
      await t.pumpWidget(_app(
        resources: _resources(algae: 4900, maxStorage: 5000),
        netProduction: {ResourceType.algae: 140},
      ));
      await _open(t);
      expect(find.text('(MAX)'), findsOneWidget);
    });

    testWidgets('shows negative net in red', (t) async {
      await t.pumpWidget(_app(netProduction: {ResourceType.algae: -10}));
      await _open(t);
      expect(find.text('100 (-10) \u2192 90'), findsOneWidget);
    });

    testWidgets('shows zero production', (t) async {
      await t.pumpWidget(_app());
      await _open(t);
      expect(find.text('100 (+0) \u2192 100'), findsOneWidget);
    });

    testWidgets('shows all producible resources', (t) async {
      await t.pumpWidget(_app());
      await _open(t);
      expect(find.text('Algues'), findsOneWidget);
      expect(find.text('Corail'), findsOneWidget);
      expect(find.text('Minerai'), findsOneWidget);
      expect(find.text('\u00c9nergie'), findsOneWidget);
      expect(find.text('Perles'), findsNothing);
    });

    testWidgets('cancel returns false', (t) async {
      await t.pumpWidget(_app());
      await _open(t);
      await t.tap(find.text('Annuler'));
      await t.pumpAndSettle();
      expect(find.text('Tour 3 \u2192 Tour 4'), findsNothing);
    });

    testWidgets('confirm returns true', (t) async {
      await t.pumpWidget(_app());
      await _open(t);
      await t.tap(find.text('Confirmer'));
      await t.pumpAndSettle();
      expect(find.text('Tour 3 \u2192 Tour 4'), findsNothing);
    });
  });
}

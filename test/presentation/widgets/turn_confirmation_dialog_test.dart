import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/resource_type.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/turn_confirmation_dialog.dart';
import '../../helpers/test_svg_helper.dart';

void main() {
  late bool? dialogResult;

  Widget createApp(Map<ResourceType, int> production) {
    return MaterialApp(
      theme: AbyssTheme.create(),
      home: Scaffold(
        body: Builder(
          builder: (ctx) => ElevatedButton(
            onPressed: () async {
              dialogResult = await showTurnConfirmationDialog(
                ctx,
                production: production,
              );
            },
            child: const Text('Open'),
          ),
        ),
      ),
    );
  }

  Future<void> openDialog(WidgetTester t) async {
    await t.tap(find.text('Open'));
    await t.pumpAndSettle();
  }

  group('TurnConfirmationDialog', () {
    setUp(() {
      mockSvgAssets();
      dialogResult = null;
    });

    tearDown(clearSvgMocks);

    testWidgets('shows title', (t) async {
      await t.pumpWidget(createApp({ResourceType.algae: 5}));
      await openDialog(t);
      expect(find.text('Passer au tour suivant ?'), findsOneWidget);
    });

    testWidgets('shows production for each resource', (t) async {
      await t.pumpWidget(createApp({
        ResourceType.algae: 5,
        ResourceType.coral: 8,
      }));
      await openDialog(t);
      expect(find.text('+5'), findsOneWidget);
      expect(find.text('+8'), findsOneWidget);
      expect(find.text('Algues'), findsOneWidget);
      expect(find.text('Corail'), findsOneWidget);
    });

    testWidgets('empty production shows message', (t) async {
      await t.pumpWidget(createApp({}));
      await openDialog(t);
      expect(find.text('Aucune production ce tour.'), findsOneWidget);
    });

    testWidgets('cancel returns false', (t) async {
      await t.pumpWidget(createApp({ResourceType.algae: 5}));
      await openDialog(t);
      await t.tap(find.text('Annuler'));
      await t.pumpAndSettle();
      expect(dialogResult, isFalse);
    });

    testWidgets('confirm returns true', (t) async {
      await t.pumpWidget(createApp({ResourceType.algae: 5}));
      await openDialog(t);
      await t.tap(find.text('Confirmer'));
      await t.pumpAndSettle();
      expect(dialogResult, isTrue);
    });
  });
}

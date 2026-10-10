import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/presentation/widgets/map/treasure_sheet.dart';

import '../../../helpers/l10n_fixtures.dart';

void main() {
  Widget buildOpener({
    required CellContentType contentType,
    VoidCallback? onCollect,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showTreasureSheet(
              context,
              targetX: 3,
              targetY: 5,
              contentType: contentType,
              onCollect: onCollect ?? () {},
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    );
  }

  group('TreasureSheet', () {
    testWidgets('resourceBonus shows algae/coral/ore description',
        (tester) async {
      await tester.pumpWidget(buildOpener(
        contentType: CellContentType.resourceBonus,
      ));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Algues, corail et minerai'), findsOneWidget);
    });

    testWidgets('ruins shows coral/ore/pearl description', (tester) async {
      await tester.pumpWidget(buildOpener(
        contentType: CellContentType.ruins,
      ));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Corail, minerai et perles'), findsOneWidget);
    });

    testWidgets('a wreck shows its coral, ore and pearl', (tester) async {
      await tester.pumpWidget(buildOpener(
        contentType: CellContentType.wreck,
      ));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Corail, minerai et une perle'), findsOneWidget);
    });

    testWidgets('displays collect button', (tester) async {
      await tester.pumpWidget(buildOpener(
        contentType: CellContentType.resourceBonus,
      ));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Collecter le trésor'), findsOneWidget);
    });

    testWidgets('tapping button calls onCollect', (tester) async {
      var called = false;
      await tester.pumpWidget(buildOpener(
        contentType: CellContentType.resourceBonus,
        onCollect: () => called = true,
      ));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Collecter le trésor'));
      await tester.pumpAndSettle();
      expect(called, isTrue);
    });
    testWidgets('a cell without treasure promises no loot', (tester) async {
      const noTreasure = [
        CellContentType.empty,
        CellContentType.monsterLair,
        CellContentType.transitionBase,
        CellContentType.passage,
        CellContentType.volcanicKernel,
      ];
      for (final content in noTreasure) {
        await tester.pumpWidget(buildOpener(contentType: content));
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        expect(find.text(fr.mapTreasureTitle(3, 5)), findsOneWidget);
        for (final loot in [
          fr.mapTreasureResourceBonus,
          fr.mapTreasureRuins,
          fr.mapTreasureWreck,
        ]) {
          expect(find.text(loot), findsNothing, reason: content.name);
        }
        await tester.pumpWidget(const SizedBox());
      }
    });
  });
}

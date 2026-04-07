import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/presentation/widgets/map/treasure_sheet.dart';

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
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/presentation/widgets/map/treasure_sheet.dart';

void main() {
  Widget buildOpener({
    required CellContentType contentType,
    ResourceType? bonusResourceType,
    int? bonusAmount,
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
              bonusResourceType: bonusResourceType,
              bonusAmount: bonusAmount,
              onCollect: onCollect ?? () {},
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    );
  }

  group('TreasureSheet', () {
    testWidgets('resourceBonus shows resource type and amount',
        (tester) async {
      await tester.pumpWidget(buildOpener(
        contentType: CellContentType.resourceBonus,
        bonusResourceType: ResourceType.coral,
        bonusAmount: 30,
      ));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Corail'), findsOneWidget);
      expect(find.text('30'), findsOneWidget);
    });

    testWidgets('ruins shows random reward description', (tester) async {
      await tester.pumpWidget(buildOpener(
        contentType: CellContentType.ruins,
      ));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(
        find.text('Ressources aléatoires et perles'),
        findsOneWidget,
      );
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

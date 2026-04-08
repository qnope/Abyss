import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/resource/resource.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import '../../../helpers/test_svg_helper.dart';
import 'building_detail_sheet_harness.dart';

void main() {
  group('BuildingDetailSheet headquarters', () {
    setUp(mockSvgAssets);
    tearDown(clearSvgMocks);

    testWidgets('shows building name and level', (t) async {
      useTallSurface(t);
      await t.pumpWidget(buildSheetApp(building: hq(2)));
      await openSheet(t);
      expect(find.text('Quartier Général'), findsOneWidget);
      expect(find.text('Niveau 2'), findsOneWidget);
    });

    testWidgets('shows building description', (t) async {
      useTallSurface(t);
      await t.pumpWidget(buildSheetApp(building: hq(1)));
      await openSheet(t);
      expect(find.textContaining('Centre de commandement'), findsOneWidget);
    });

    testWidgets('shows upgrade costs with amounts', (t) async {
      useTallSurface(t);
      await t.pumpWidget(buildSheetApp(building: hq()));
      await openSheet(t);
      expect(find.text('80/30'), findsOneWidget);
      expect(find.text('50/20'), findsOneWidget);
    });

    testWidgets('upgrade button enabled with sufficient resources',
        (t) async {
      useTallSurface(t);
      await t.pumpWidget(buildSheetApp(building: hq()));
      await openSheet(t);
      final btn = t.widget<ElevatedButton>(
        find.byType(ElevatedButton).last,
      );
      expect(btn.onPressed, isNotNull);
    });

    testWidgets('upgrade button disabled with insufficient resources',
        (t) async {
      useTallSurface(t);
      final poor = {
        for (final type in ResourceType.values)
          type: Resource(type: type, amount: 1),
      };
      await t.pumpWidget(buildSheetApp(building: hq(), resources: poor));
      await openSheet(t);
      final btn = t.widget<ElevatedButton>(
        find.byType(ElevatedButton).last,
      );
      expect(btn.onPressed, isNull);
    });

    testWidgets('shows max level message at level 10', (t) async {
      useTallSurface(t);
      await t.pumpWidget(buildSheetApp(building: hq(10)));
      await openSheet(t);
      expect(find.text('Niveau maximum atteint'), findsOneWidget);
    });

    testWidgets('shows Construire button when level 0', (t) async {
      useTallSurface(t);
      await t.pumpWidget(buildSheetApp(building: hq()));
      await openSheet(t);
      expect(find.text('Construire'), findsOneWidget);
    });

    testWidgets('shows Améliorer button when level > 0', (t) async {
      useTallSurface(t);
      await t.pumpWidget(buildSheetApp(building: hq(1)));
      await openSheet(t);
      expect(find.text('Améliorer'), findsOneWidget);
    });
  });
}

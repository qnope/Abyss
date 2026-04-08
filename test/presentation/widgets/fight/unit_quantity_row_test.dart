import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/fight/unit_quantity_row.dart';
import '../../../helpers/test_svg_helper.dart';

void main() {
  group('UnitQuantityRow', () {
    setUp(mockSvgAssets);
    tearDown(clearSvgMocks);

    Widget createApp({
      UnitType type = UnitType.scout,
      int stock = 10,
      int value = 0,
      ValueChanged<int>? onChanged,
    }) {
      return MaterialApp(
        theme: AbyssTheme.create(),
        home: Scaffold(
          body: UnitQuantityRow(
            type: type,
            stock: stock,
            value: value,
            onChanged: onChanged ?? (_) {},
          ),
        ),
      );
    }

    testWidgets('renders unit label and stock', (tester) async {
      await tester.pumpWidget(createApp(stock: 10));
      await tester.pumpAndSettle();
      expect(find.text('Eclaireur'), findsOneWidget);
      expect(find.text('Stock: 10'), findsOneWidget);
    });

    testWidgets('renders current value', (tester) async {
      await tester.pumpWidget(createApp(value: 3));
      await tester.pumpAndSettle();
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('tapping + calls onChanged(value + 1)', (tester) async {
      int? received;
      await tester.pumpWidget(
        createApp(value: 2, stock: 5, onChanged: (v) => received = v),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.add));
      expect(received, 3);
    });

    testWidgets('tapping - calls onChanged(value - 1)', (tester) async {
      int? received;
      await tester.pumpWidget(
        createApp(value: 2, stock: 5, onChanged: (v) => received = v),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.remove));
      expect(received, 1);
    });

    testWidgets('- button disabled when value == 0', (tester) async {
      var called = false;
      await tester.pumpWidget(
        createApp(value: 0, stock: 5, onChanged: (_) => called = true),
      );
      await tester.pumpAndSettle();
      final button = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.remove),
      );
      expect(button.onPressed, isNull);
      await tester.tap(find.byIcon(Icons.remove));
      expect(called, isFalse);
    });

    testWidgets('+ button disabled when value == stock', (tester) async {
      var called = false;
      await tester.pumpWidget(
        createApp(value: 5, stock: 5, onChanged: (_) => called = true),
      );
      await tester.pumpAndSettle();
      final button = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.add),
      );
      expect(button.onPressed, isNull);
      await tester.tap(find.byIcon(Icons.add));
      expect(called, isFalse);
    });

    testWidgets('renders Slider with correct max', (tester) async {
      await tester.pumpWidget(createApp(stock: 5));
      await tester.pumpAndSettle();
      final slider = tester.widget<Slider>(find.byType(Slider));
      expect(slider.max, 5.0);
      expect(slider.divisions, 5);
    });

    testWidgets('slider value reflects current value', (tester) async {
      await tester.pumpWidget(createApp(value: 3, stock: 5));
      await tester.pumpAndSettle();
      final slider = tester.widget<Slider>(find.byType(Slider));
      expect(slider.value, 3.0);
    });

    testWidgets('dragging slider calls onChanged with rounded int', (
      tester,
    ) async {
      int? received;
      await tester.pumpWidget(
        createApp(value: 0, stock: 5, onChanged: (v) => received = v),
      );
      await tester.pumpAndSettle();
      final slider = tester.widget<Slider>(find.byType(Slider));
      slider.onChanged?.call(2.7);
      expect(received, 3);
    });

    testWidgets('stock == 1 still renders slider with max 1', (tester) async {
      await tester.pumpWidget(createApp(stock: 1, value: 0));
      await tester.pumpAndSettle();
      final slider = tester.widget<Slider>(find.byType(Slider));
      expect(slider.max, 1.0);
      expect(slider.divisions, 1);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/presentation/widgets/map/cell_info_sheet.dart';

void main() {
  Widget buildOpener({
    required String title,
    required String message,
    IconData? icon,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showCellInfoSheet(
              context,
              title: title,
              message: message,
              icon: icon,
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    );
  }

  group('CellInfoSheet', () {
    testWidgets('displays title text', (tester) async {
      await tester.pumpWidget(buildOpener(
        title: 'Test Title',
        message: 'Test Message',
      ));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Test Title'), findsOneWidget);
    });

    testWidgets('displays message text', (tester) async {
      await tester.pumpWidget(buildOpener(
        title: 'Title',
        message: 'Some message content',
      ));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Some message content'), findsOneWidget);
    });

    testWidgets('displays icon when provided', (tester) async {
      await tester.pumpWidget(buildOpener(
        title: 'Title',
        message: 'Message',
        icon: Icons.explore,
      ));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.explore), findsOneWidget);
    });

    testWidgets('no icon when not provided', (tester) async {
      await tester.pumpWidget(buildOpener(
        title: 'Title',
        message: 'Message',
      ));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.explore), findsNothing);
    });
  });
}

import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/map/exploration_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> openSheet(
    WidgetTester tester, {
    int scoutCount = 2,
    int revealSide = 3,
    bool isEligible = true,
    String? refusal,
    VoidCallback? onConfirm,
  }) async {
    await tester.pumpWidget(MaterialApp(
      theme: AbyssTheme.create(),
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => showExplorationSheet(
              context,
              targetX: 3,
              targetY: 8,
              scoutCount: scoutCount,
              revealSide: revealSide,
              isEligible: isEligible,
              refusal: refusal,
              onConfirm: onConfirm ?? () {},
            ),
            child: const Text('open'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  FilledButton sendButton(WidgetTester tester) =>
      tester.widget<FilledButton>(find.byType(FilledButton));

  testWidgets('shows target, cost, scouts and revealed area',
      (tester) async {
    await openSheet(tester, scoutCount: 4, revealSide: 5);

    expect(find.text('Explorer (3, 8)'), findsOneWidget);
    expect(find.text('1 éclaireur'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('5×5 cellules'), findsOneWidget);
  });

  testWidgets('sending closes the sheet then confirms', (tester) async {
    var confirmed = 0;
    await openSheet(tester, onConfirm: () => confirmed++);

    expect(sendButton(tester).onPressed, isNotNull);
    await tester.tap(find.text('Envoyer'));
    await tester.pumpAndSettle();

    expect(confirmed, 1);
    expect(find.text('Explorer (3, 8)'), findsNothing);
  });

  testWidgets('without scouts the send button is disabled', (tester) async {
    await openSheet(tester, scoutCount: 0);

    expect(find.text('Aucun éclaireur disponible'), findsOneWidget);
    expect(sendButton(tester).onPressed, isNull);
  });

  testWidgets('an ineligible cell disables the send button', (tester) async {
    await openSheet(tester, isEligible: false);

    expect(find.text('Cellule non éligible'), findsOneWidget);
    expect(sendButton(tester).onPressed, isNull);
  });

  testWidgets('a refusal disables the send button and says why', (
    tester,
  ) async {
    await openSheet(tester, refusal: 'Tempête : exploration impossible');

    expect(find.text('Tempête : exploration impossible'), findsOneWidget);
    expect(sendButton(tester).onPressed, isNull);
  });
}

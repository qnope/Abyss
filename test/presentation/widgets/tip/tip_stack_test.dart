import 'package:abyss/domain/objective/tip/tip_catalog.dart';
import 'package:abyss/domain/objective/tip/tip_id.dart';
import 'package:abyss/presentation/widgets/tip/tip_stack.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/localized_app.dart';
import '../../../helpers/test_svg_helper.dart';

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  final ids = [TipId.noiseGauge, TipId.events, TipId.lair];

  Future<void> open(WidgetTester tester, List<TipId> shown) async {
    await tester.pumpWidget(
      localizedApp(
        Scaffold(
          body: Builder(
            builder:
                (context) => TextButton(
                  onPressed:
                      () => showTipStack(context, [
                        for (final id in shown) TipCatalog.byId(id),
                      ]),
                  child: const Text('open'),
                ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('a lone tip shows as a plain card closed by « Compris »', (
    tester,
  ) async {
    await open(tester, [TipId.lair]);
    expect(find.text('Les repaires'), findsOneWidget);
    expect(find.textContaining(' / '), findsNothing);
    await tester.tap(find.text('Compris'));
    await tester.pumpAndSettle();
    expect(find.byType(TipStack), findsNothing);
  });

  testWidgets('shows the first tip on top with its rank', (tester) async {
    await open(tester, ids);
    expect(find.text('La jauge de bruit'), findsOneWidget);
    expect(find.text('Les événements'), findsNothing);
    expect(find.text('1 / 3'), findsOneWidget);
    expect(find.text('Suivant'), findsOneWidget);
    expect(find.text('Compris'), findsNothing);
  });

  testWidgets('« Suivant » brings the next card, the last one closes', (
    tester,
  ) async {
    await open(tester, ids);
    await tester.tap(find.text('Suivant'));
    await tester.pumpAndSettle();
    expect(find.text('Les événements'), findsOneWidget);
    expect(find.text('2 / 3'), findsOneWidget);
    await tester.tap(find.text('Suivant'));
    await tester.pumpAndSettle();
    expect(find.text('3 / 3'), findsOneWidget);
    expect(find.text('Suivant'), findsNothing);
    await tester.tap(find.text('Compris'));
    await tester.pumpAndSettle();
    expect(find.byType(TipStack), findsNothing);
  });

  testWidgets('a swipe goes forward and back', (tester) async {
    await open(tester, ids);
    await tester.fling(find.byType(TipStack), const Offset(-300, 0), 1000);
    await tester.pumpAndSettle();
    expect(find.text('2 / 3'), findsOneWidget);
    await tester.fling(find.byType(TipStack), const Offset(300, 0), 1000);
    await tester.pumpAndSettle();
    expect(find.text('1 / 3'), findsOneWidget);
  });

  testWidgets('the cards waiting peek out behind the one on top', (
    tester,
  ) async {
    await open(tester, ids);
    expect(find.byKey(const ValueKey('tip-stack-behind')), findsNWidgets(2));
    await tester.tap(find.text('Suivant'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('tip-stack-behind')), findsNWidgets(1));
  });
}

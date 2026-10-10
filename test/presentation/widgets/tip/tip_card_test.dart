import 'dart:io';

import 'package:abyss/domain/event/random_event_type.dart';
import 'package:abyss/domain/objective/tip/event_tips.dart';
import 'package:abyss/domain/objective/tip/tip_catalog.dart';
import 'package:abyss/domain/objective/tip/tip_id.dart';
import 'package:abyss/presentation/extensions/random_event_type_extensions.dart';
import 'package:abyss/presentation/extensions/tip_id_extensions.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/common/raster_svg.dart';
import 'package:abyss/presentation/widgets/tip/tip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_svg_helper.dart';

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  Future<void> open(WidgetTester tester, TipId id) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AbyssTheme.create(),
        home: Scaffold(
          body: Builder(
            builder:
                (context) => TextButton(
                  onPressed: () => showTipCard(context, TipCatalog.byId(id)),
                  child: const Text('open'),
                ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('shows the illustration, the title and the lines', (
    tester,
  ) async {
    await open(tester, TipId.noiseGauge);
    final tip = TipCatalog.byId(TipId.noiseGauge);
    final art = tester.widget<RasterSvg>(find.byType(RasterSvg));
    expect(art.assetPath, TipId.noiseGauge.illustration);
    expect(find.text('La jauge de bruit'), findsOneWidget);
    for (final line in tip.lines) {
      expect(find.text(line), findsOneWidget);
    }
  });

  testWidgets('« Compris » closes the card', (tester) async {
    await open(tester, TipId.lair);
    expect(find.byType(TipCard), findsOneWidget);
    await tester.tap(find.text('Compris'));
    await tester.pumpAndSettle();
    expect(find.byType(TipCard), findsNothing);
  });

  test('an event tip shows the illustration of its event', () {
    for (final type in RandomEventType.values) {
      expect(EventTips.idOf(type).illustration, type.illustration);
    }
  });

  test('every illustration is an asset of the game', () {
    for (final id in TipId.values) {
      expect(File(id.illustration).existsSync(), isTrue, reason: id.name);
    }
  });
}

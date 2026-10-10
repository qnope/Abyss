import 'package:abyss/domain/game/save_outcome.dart';
import 'package:abyss/presentation/theme/abyss_card_theme.dart';
import 'package:abyss/presentation/widgets/common/raster_svg.dart';
import 'package:abyss/presentation/widgets/common/status_pill.dart';
import 'package:abyss/presentation/widgets/resource/resource_icon.dart';
import 'package:abyss/presentation/widgets/save/save_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/save_card_harness.dart';
import '../../../helpers/save_summary_helpers.dart';

Finder _panel({required bool highlighted}) => find.byWidgetPredicate(
  (w) =>
      w is DecoratedBox &&
      w.decoration == AbyssCardTheme.savePanel(highlighted: highlighted),
);

final _thumbnail = find.byWidgetPredicate(
  (w) => w is RasterSvg && w.size == SaveCard.thumbnailSize,
);

void main() {
  testWidgets('shows a game in progress', (tester) async {
    await tester.pumpWidget(saveCardApp(summaryOf()));

    expect(find.text('Alice'), findsOneWidget);
    expect(find.text('NORMAL'), findsOneWidget);
    expect(find.text('Tour 14 · Profondeurs · QG niv. 3'), findsOneWidget);
    expect(find.text('il y a 2 h'), findsOneWidget);
    expect(tester.widget<RasterSvg>(_thumbnail).greyscale, isFalse);
    expect(tester.widget<StatusPill>(find.byType(StatusPill)).faded, isFalse);
  });

  testWidgets('lists the five resources with their icons', (tester) async {
    await tester.pumpWidget(saveCardApp(summaryOf()));

    expect(find.byType(ResourceIcon), findsNWidgets(5));
    for (final amount in ['412', '298', '186', '74', '9']) {
      expect(find.text(amount), findsOneWidget);
    }
  });

  testWidgets('a won game shows its badge and conquest', (tester) async {
    await tester.pumpWidget(
      saveCardApp(
        summaryOf(
          outcome: SaveOutcome.victory,
          volcanicKernelCaptured: true,
          lastPlayedAt: DateTime(2026, 10, 5),
        ),
      ),
    );

    expect(find.text('★ VICTOIRE'), findsOneWidget);
    expect(find.text('Noyau volcanique conquis'), findsOneWidget);
    expect(find.text('5 oct.'), findsOneWidget);
    expect(find.byType(ResourceIcon), findsNothing);
  });

  testWidgets('a lost game is greyed out', (tester) async {
    await tester.pumpWidget(
      saveCardApp(summaryOf(outcome: SaveOutcome.defeat)),
    );

    expect(find.text('DÉFAITE'), findsOneWidget);
    expect(find.text('Voir le bilan de la partie'), findsOneWidget);
    final thumbnail = tester.widget<RasterSvg>(_thumbnail);
    expect(thumbnail.greyscale, isTrue);
    expect(thumbnail.assetPath, endsWith('depth_deep.svg'));
    expect(tester.widget<StatusPill>(find.byType(StatusPill)).faded, isTrue);
    expect(find.byType(Opacity), findsNothing);
  });

  testWidgets('glows when highlighted only', (tester) async {
    await tester.pumpWidget(saveCardApp(summaryOf()));
    expect(_panel(highlighted: false), findsOneWidget);

    await tester.pumpWidget(saveCardApp(summaryOf(), highlighted: true));
    expect(_panel(highlighted: true), findsOneWidget);
  });

  testWidgets('tapping the card opens the game', (tester) async {
    var opened = 0;
    await tester.pumpWidget(saveCardApp(summaryOf(), onTap: () => opened++));

    await tester.tap(find.text('Alice'));
    expect(opened, 1);
  });

  testWidgets('deletes from its options menu without opening the game', (
    tester,
  ) async {
    var opened = 0;
    var deleted = 0;
    await tester.pumpWidget(
      saveCardApp(
        summaryOf(),
        onTap: () => opened++,
        onDelete: () => deleted++,
      ),
    );

    await tester.tap(find.byTooltip('Options'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    await tester.tap(find.text('Supprimer'));
    await tester.pumpAndSettle();

    expect(deleted, 1);
    expect(opened, 0);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/map/transition_base.dart';
import 'package:abyss/domain/map/transition_base_type.dart';
import 'package:abyss/presentation/l10n/abyss_locale.dart';
import 'package:abyss/presentation/widgets/common/raster_svg.dart';
import 'package:abyss/presentation/widgets/map/cell_info_sheet.dart';
import 'package:abyss/presentation/widgets/map/rival_post_sheet.dart';

import 'transition_base_sheet_helper.dart';

void main() {
  Finder illustration(String path) => find.byWidgetPredicate(
      (w) => w is RasterSvg && w.assetPath == path);

  testWidgets('a guarded Faille shows its guardians', (t) async {
    await t.pumpWidget(buildSheetOpener(
        base: TransitionBase(type: TransitionBaseType.faille, name: 'F')));
    await openSheet(t);
    expect(illustration('assets/icons/posts/faille_guarded.svg'),
        findsOneWidget);
    expect(find.byIcon(Icons.waves), findsNothing);
  });

  testWidgets('a Cheminée the human holds is lit green', (t) async {
    await t.pumpWidget(buildSheetOpener(
        base: TransitionBase(
            type: TransitionBaseType.cheminee, name: 'C', capturedBy: 'me')));
    await openSheet(t);
    expect(illustration('assets/icons/posts/cheminee_player.svg'),
        findsOneWidget);
  });

  testWidgets('a post a faction holds is lit red', (t) async {
    await t.pumpWidget(MaterialApp(
      locale: AbyssLocale.fr,
      localizationsDelegates: AbyssLocale.delegates,
      supportedLocales: AbyssLocale.supported,
      home: Scaffold(
        body: RivalPostSheet(
          post: TransitionBase(type: TransitionBaseType.faille, name: 'F',
              capturedBy: 'murenes'),
          ownerName: 'Murènes',
          refusal: null,
          onAttack: () {},
        ),
      ),
    ));
    expect(illustration('assets/icons/posts/faille_faction.svg'),
        findsOneWidget);
  });

  testWidgets('a cell sheet can show an illustration', (t) async {
    await t.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (ctx) => ElevatedButton(
            onPressed: () => showCellInfoSheet(ctx,
                title: 'Passage', message: 'm',
                illustration: 'assets/icons/posts/passage_faille_player.svg'),
            child: const Text('Open'),
          ),
        ),
      ),
    ));
    await openSheet(t);
    expect(illustration('assets/icons/posts/passage_faille_player.svg'),
        findsOneWidget);
  });
}

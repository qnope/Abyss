import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/objective/objective_id.dart';
import 'package:abyss/presentation/extensions/guide_message_extensions.dart';
import 'package:abyss/presentation/screens/game/game_screen.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/building/building_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_game_repository.dart';
import '../../../helpers/guide_helpers.dart';
import '../../../helpers/l10n_fixtures.dart';
import '../../../helpers/objective_helpers.dart';
import '../../../helpers/test_svg_helper.dart';
import '../../widgets/guide/guide_widget_helpers.dart';

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  Future<void> pumpScreen(WidgetTester tester, Game game) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AbyssTheme.create(),
        home: GameScreen(game: game, repository: FakeGameRepository()),
      ),
    );
    await tester.pump();
  }

  final hqCard = find.byWidgetPredicate(
    (widget) =>
        widget is BuildingCard &&
        widget.building.type == BuildingType.headquarters,
  );

  testWidgets('the guide shows its lesson and points at the HQ card', (
    tester,
  ) async {
    await pumpScreen(tester, guideGame(ObjectiveId.hqLevel1));

    expect(find.text(ObjectiveId.hqLevel1.lesson(fr)!), findsOneWidget);
    expect(activeHalos, findsOneWidget);
    expect(haloAround(hqCard), findsOneWidget);
  });

  testWidgets('« Compris » hides the bubble but keeps the halo', (
    tester,
  ) async {
    await pumpScreen(tester, guideGame(ObjectiveId.hqLevel1));

    await tester.tap(find.text('Compris'));
    await tester.pump();

    expect(find.text('Compris'), findsNothing);
    expect(haloAround(hqCard), findsOneWidget);
  });

  testWidgets('the halo shows the tab to open, then leaves it once open', (
    tester,
  ) async {
    await pumpScreen(tester, guideGame(ObjectiveId.explore));

    expect(find.text(ObjectiveId.explore.lesson(fr)!), findsOneWidget);
    expect(haloAround(find.byIcon(Icons.map)), findsOneWidget);

    await tester.tap(find.text('Carte'));
    await tester.pump();

    expect(activeHalos, findsNothing);
    expect(find.text('Compris'), findsOneWidget);
  });

  testWidgets('a goal met points at « Tour suivant »', (tester) async {
    final game = guideGame(ObjectiveId.hqLevel1);
    setBuilding(game.humanPlayer, BuildingType.headquarters, 1);

    await pumpScreen(tester, game);

    expect(find.text(fr.guideGoalMet), findsOneWidget);
    expect(activeHalos, findsOneWidget);
    expect(haloAround(find.text('Tour suivant')), findsOneWidget);
  });

  testWidgets('no guide when the tutorial is off', (tester) async {
    await pumpScreen(tester, guideGame(ObjectiveId.hqLevel1, tutorial: false));

    expect(find.text('Compris'), findsNothing);
    expect(activeHalos, findsNothing);
  });

  testWidgets('no guide once the tutorial chapter is done', (tester) async {
    await pumpScreen(tester, guideGame(ObjectiveId.takeLair));

    expect(find.text('Compris'), findsNothing);
    expect(activeHalos, findsNothing);
  });
}

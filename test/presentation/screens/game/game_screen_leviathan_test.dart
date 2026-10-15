import 'package:abyss/domain/objective/objective_migration.dart';
import 'package:abyss/presentation/screens/game/game_screen.dart';
import 'package:abyss/presentation/widgets/map/game_map_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../domain/leviathan/leviathan_scene.dart';
import '../../../helpers/fake_game_repository.dart';
import '../../../helpers/l10n_fixtures.dart';
import '../../../helpers/localized_app.dart';
import '../../../helpers/test_svg_helper.dart';
import '../../../helpers/reduced_motion.dart';

void main() {
  reduceMotionInEveryTest();
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  testWidgets('the counter-attack banner opens the map of the Faille', (
    tester,
  ) async {
    final war = leviathanScene();
    war.playUntil(war.strikeTurn);
    ObjectiveMigration.stateOf(war.game, war.human).tipsEnabled = false;
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      localizedApp(GameScreen(game: war.game, repository: FakeGameRepository())),
    );
    await tester.pumpAndSettle();
    expect(find.byType(GameMapView), findsNothing);

    await tester.tap(find.text(fr.leviathanBannerTitle));
    await tester.pumpAndSettle();

    final view = tester.widget<GameMapView>(find.byType(GameMapView));
    expect(view.gameMap, same(war.game.levels[war.level]));
  });
}

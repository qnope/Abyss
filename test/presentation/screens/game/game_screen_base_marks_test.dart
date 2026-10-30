import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/presentation/screens/game/game_screen.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/base/base_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_game_repository.dart';
import '../../../helpers/objective_helpers.dart';
import '../../../helpers/test_svg_helper.dart';

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  Future<BaseView> baseOf(WidgetTester tester, Game game) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AbyssTheme.create(),
        home: GameScreen(game: game, repository: FakeGameRepository()),
      ),
    );
    await tester.pump();
    return tester.widget<BaseView>(find.byType(BaseView));
  }

  testWidgets('a new base locks every plot but the headquarters', (
    tester,
  ) async {
    final base = await baseOf(tester, objectiveGame());
    expect(base.locked, contains(BuildingType.algaeFarm));
    expect(base.locked, isNot(contains(BuildingType.headquarters)));
    expect(base.upgradable, {BuildingType.headquarters});
  });

  testWidgets('the base shows what can rise by the rules of the sheet', (
    tester,
  ) async {
    final game = objectiveGame();
    final human = game.humanPlayer;
    human.buildings[BuildingType.headquarters]!.level = 2;
    for (final type in ResourceType.values) {
      human.resources[type]!.amount = 5000;
    }
    final base = await baseOf(tester, game);
    expect(base.upgradable, contains(BuildingType.algaeFarm));
    expect(base.upgradable, contains(BuildingType.headquarters));
    expect(base.locked, contains(BuildingType.descentModule));
  });

  testWidgets('no worksite left: nothing can rise', (tester) async {
    final game = objectiveGame();
    game.humanPlayer.worksite.upgrades = 1;
    final base = await baseOf(tester, game);
    expect(base.upgradable, isEmpty);
  });
}

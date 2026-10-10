import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/map/map_generator.dart';
import 'package:abyss/domain/resource/resource.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/tech/tech_branch.dart';
import 'package:abyss/presentation/extensions/tech_branch_extensions.dart';
import 'package:abyss/presentation/extensions/tech_node_extensions.dart';
import 'package:abyss/presentation/screens/game/game_screen.dart';
import 'package:abyss/presentation/widgets/map/game_map_view.dart';
import 'package:abyss/presentation/widgets/map/map_level_info.dart';
import 'package:abyss/presentation/widgets/tech/tech_node_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_game_repository.dart';
import '../../../helpers/l10n_fixtures.dart';
import '../../../helpers/localized_app.dart';
import '../../../helpers/test_svg_helper.dart';

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  /// A game with a laboratory, full stocks and the first two depths.
  Game newGame() {
    final gen = MapGenerator.generate(seed: 1);
    final player = Player.withBase(
      name: 'Nemo',
      baseX: gen.baseX,
      baseY: gen.baseY,
      mapWidth: gen.map.width,
      mapHeight: gen.map.height,
    );
    player.buildings[BuildingType.laboratory] =
        Building(type: BuildingType.laboratory, level: 1);
    for (final type in ResourceType.values) {
      player.resources[type] =
          Resource(type: type, amount: 900, maxStorage: 1000);
    }
    return Game.singlePlayer(player)
      ..levels = {
        1: gen.map,
        2: MapGenerator.generate(seed: 2, level: 2).map,
      };
  }

  /// Shows [game] on a tall tablet, on the tab labelled [tab].
  Future<void> openTab(WidgetTester tester, Game game, String tab) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(localizedApp(
      GameScreen(game: game, repository: FakeGameRepository()),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text(tab));
    await tester.pumpAndSettle();
  }

  testWidgets('choosing a deeper level shows its map', (tester) async {
    final game = newGame();
    await openTab(tester, game, fr.screenTabMap);

    await tester.tap(find.text(fr.mapLevelChip(2, MapLevelInfo.nameOf(fr, 2))));
    await tester.pumpAndSettle();

    final view = tester.widget<GameMapView>(find.byType(GameMapView));
    expect(view.gameMap, same(game.levels[2]));
  });

  testWidgets('unlocking a branch from the research tab', (tester) async {
    final game = newGame();
    await openTab(tester, game, fr.screenTabTech);

    await tester.tap(find.textContaining(TechBranch.explorer.displayName(fr)));
    await tester.pumpAndSettle();
    await tester.tap(find.text(fr.techScreenUnlock));
    await tester.pumpAndSettle();

    final branch = game.humanPlayer.techBranches[TechBranch.explorer]!;
    expect(branch.unlocked, isTrue);
  });

  testWidgets('researching a node from the research tab', (tester) async {
    final game = newGame();
    game.humanPlayer.techBranches[TechBranch.explorer]!.unlocked = true;
    await openTab(tester, game, fr.screenTabTech);

    await tester.tap(find.byWidgetPredicate((w) =>
        w is TechNodeWidget &&
        w.iconPath == TechBranch.explorer.nodeIconPath(1)));
    await tester.pumpAndSettle();
    await tester.tap(find.text(fr.techScreenResearch));
    await tester.pumpAndSettle();

    final branch = game.humanPlayer.techBranches[TechBranch.explorer]!;
    expect(branch.researchLevel, 1);
  });
}

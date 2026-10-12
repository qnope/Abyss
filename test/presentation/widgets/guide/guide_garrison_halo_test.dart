import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/map/map_cell.dart';
import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/domain/objective/objective_catalog.dart';
import 'package:abyss/domain/objective/objective_id.dart';
import 'package:abyss/domain/objective/objective_state.dart';
import 'package:abyss/domain/volcano/volcano_wave_factory.dart';
import 'package:abyss/presentation/screens/game/game_screen_actions.dart';
import 'package:abyss/presentation/widgets/volcano/kernel_garrison_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_game_repository.dart';
import '../../../helpers/kernel_garrison_helpers.dart';
import '../../../helpers/l10n_fixtures.dart';
import '../../../helpers/map_tab_harness.dart';
import '../../../helpers/reduced_motion.dart';
import '../../../helpers/test_svg_helper.dart';
import '../../../helpers/transition_fight_fixtures.dart';
import 'guide_widget_helpers.dart';

/// A kernel held on level 1 at (2, 2), the tutorial on its first level,
/// a kraken wave announced when [wave].
Game _game({bool wave = true}) {
  final game = kernelGarrisonGame();
  game.levels[1] = plainMap({
    GridPosition(x: 2, y: 2): MapCell(
      terrain: TerrainType.plain,
      content: CellContentType.volcanicKernel,
      collectedBy: game.humanPlayer.id,
    ),
  });
  game.humanPlayer.revealedCellsPerLevel[1] = allPositions();
  game.humanPlayer.savedObjectiveState = ObjectiveState(
    tutorialEnabled: true,
    completed: [
      for (final o in ObjectiveCatalog.all.takeWhile(
        (o) => o.id != ObjectiveId.kernelLevel1,
      ))
        o.id,
    ],
  );
  if (wave) {
    game.humanPlayer.volcanoState.announce(
      VolcanoWaveFactory.fromKernelLevel(1),
      game.turn,
    );
  }
  return game;
}

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  final Finder button = find.text(fr.volcanoGarrisonUnits);

  testWidgets('the panel surrounds its garrison button when guided', (
    tester,
  ) async {
    Widget panel(bool guided) => guidedApp(
      KernelGarrisonPanel(
        player: Player(name: 'Nemo'),
        onGarrison: () {},
        onWithdraw: () {},
        guided: guided,
      ),
      null,
    );
    await tester.pumpWidget(panel(true));
    expect(haloAround(button), findsOneWidget);
    await tester.pumpWidget(panel(false));
    expect(activeHalos, findsNothing);
  });

  group('a wave announced against a small garrison', () {
    testWidgets('surrounds the button of the kernel sheet', (tester) async {
      reduceMotion(tester);
      await tester.pumpWidget(mapTabHost(_game()));
      await tester.pumpAndSettle();
      await tapMapCell(tester, 2, 2);
      expect(haloAround(button), findsOneWidget);
    });

    testWidgets('and of the kernel building sheet', (tester) async {
      reduceMotion(tester);
      final game = _game();
      useTallView(tester);
      await tester.pumpWidget(
        buildLauncherHost(
          'go',
          (ctx) => showBuildingDetailAction(
            ctx,
            game,
            FakeGameRepository(),
            Building(type: BuildingType.volcanicKernel, level: 1),
            () {},
          ),
        ),
      );
      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();
      expect(haloAround(button), findsOneWidget);
    });

    testWidgets('nothing without a wave', (tester) async {
      await tester.pumpWidget(mapTabHost(_game(wave: false)));
      await tester.pumpAndSettle();
      await tapMapCell(tester, 2, 2);
      expect(button, findsOneWidget);
      expect(haloAround(button), findsNothing);
    });
  });
}

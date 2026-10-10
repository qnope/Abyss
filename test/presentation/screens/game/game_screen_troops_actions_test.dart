import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/game_map.dart';
import 'package:abyss/domain/map/map_cell.dart';
import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/presentation/screens/game/descent_dialog.dart';
import 'package:abyss/presentation/screens/game/game_screen_actions.dart';
import 'package:abyss/presentation/screens/game/game_screen_troops_actions.dart';
import 'package:abyss/presentation/widgets/volcano/kernel_garrison_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_game_repository.dart';
import '../../../helpers/test_svg_helper.dart';
import '../../../helpers/transition_fight_fixtures.dart';
import '../../../integration/transition_test_helper.dart';

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  final repo = FakeGameRepository();

  Game scenario({bool captured = true}) {
    final game = buildTransitionScenario().game;
    game.levels = {
      1: buildMapWithFaille(capturedBy: captured ? 'player-1' : null),
    };
    return game;
  }

  Building built(BuildingType type) => Building(type: type, level: 1);

  Widget? sectionIn(BuildContext ctx, Game game, Building b) =>
      troopsSectionFor(ctx, game, repo, b, () {});

  Future<Widget?> section(
    WidgetTester tester, Game game, Building b,
  ) async {
    Widget? result;
    await tester.pumpWidget(buildLauncherHost(
      'go', (ctx) => result = sectionIn(ctx, game, b)));
    await tester.tap(find.text('go'));
    await tester.pump();
    return result;
  }

  testWidgets('a Module with no captured Faille moves no troops',
      (tester) async {
    expect(
      await section(
        tester, scenario(captured: false), built(BuildingType.descentModule)),
      isNull,
    );
  });

  testWidgets('an unbuilt Module moves no troops', (tester) async {
    expect(
      await section(tester, scenario(),
          Building(type: BuildingType.descentModule)),
      isNull,
    );
  });

  testWidgets('the Module sheet descends through the captured Faille',
      (tester) async {
    final game = scenario();
    useTallView(tester);
    await tester.pumpWidget(buildLauncherHost('go', (ctx) =>
        showBuildingDetailAction(
          ctx, game, repo, built(BuildingType.descentModule), () {})));
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();
    expect(
        find.text('Descendre des troupes par Faille Alpha'), findsOneWidget);

    await tester.tap(find.text('Descendre des troupes par Faille Alpha'));
    await tester.pumpAndSettle();
    expect(find.byType(DescentDialog), findsOneWidget);
    expect(find.text('Descente vers le Niveau 2'), findsOneWidget);
  });

  testWidgets('a captured kernel shows its garrison panel', (tester) async {
    final game = scenario();
    game.levels[3] = GameMap(
      width: 1,
      height: 1,
      seed: 0,
      cells: [
        MapCell(
          terrain: TerrainType.plain,
          content: CellContentType.volcanicKernel,
          collectedBy: 'player-1',
        ),
      ],
    );
    final widget =
        await section(tester, game, built(BuildingType.volcanicKernel));
    expect(widget, isA<KernelGarrisonPanel>());
  });

  testWidgets('an uncaptured kernel shows no garrison', (tester) async {
    expect(
      await section(tester, scenario(), built(BuildingType.volcanicKernel)),
      isNull,
    );
  });
}

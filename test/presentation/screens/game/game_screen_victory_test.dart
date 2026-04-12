import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/game_status.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/game_map.dart';
import 'package:abyss/domain/map/map_cell.dart';
import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/presentation/screens/game/game_screen.dart';
import 'package:abyss/presentation/screens/game/victory_screen.dart';
import 'package:abyss/presentation/screens/menu/main_menu_screen.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import '../../../helpers/fake_game_repository.dart';
import '../../../helpers/test_svg_helper.dart';

Game _makeKernelGame({required int kernelLevel}) {
  final player = Player(name: 'N', buildings: {
    for (final t in BuildingType.values)
      t: Building(type: t, level: t == BuildingType.headquarters ? 10
          : t == BuildingType.volcanicKernel ? kernelLevel : 1),
  });
  for (final r in player.resources.values) {
    r.amount = 99999;
  }
  const s = 5;
  final cells = List.generate(
    s * s, (_) => MapCell(terrain: TerrainType.plain));
  cells[0] = MapCell(
    terrain: TerrainType.plain,
    content: CellContentType.volcanicKernel,
    collectedBy: player.id,
  );
  return Game.singlePlayer(player)..levels = {
    1: GameMap(width: s, height: s, seed: 1,
      cells: List.generate(s * s, (_) => MapCell(terrain: TerrainType.plain))),
    3: GameMap(width: s, height: s, seed: 1, cells: cells),
  };
}

void _setLargeScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1.0;
}

void main() {
  late FakeGameRepository repo;
  setUp(() { mockSvgAssets(); repo = FakeGameRepository(); });
  tearDown(clearSvgMocks);

  Widget app(Game g) => MaterialApp(
    theme: AbyssTheme.create(),
    home: GameScreen(game: g, repository: repo),
  );

  Future<void> upgradeKernel(WidgetTester t, Game g) async {
    await t.pumpWidget(app(g));
    await t.pumpAndSettle();
    await t.tap(find.text('Noyau Volcanique'));
    await t.pumpAndSettle();
    await t.tap(find.text('Améliorer'));
    await t.pumpAndSettle();
  }

  group('victory wiring', () {
    testWidgets('upgrading HQ does not trigger victory', (t) async {
      _setLargeScreen(t);
      addTearDown(() { t.view.resetPhysicalSize(); t.view.resetDevicePixelRatio(); });
      final game = _makeKernelGame(kernelLevel: 9);
      game.humanPlayer.buildings[BuildingType.headquarters]!.level = 5;
      await t.pumpWidget(app(game));
      await t.pumpAndSettle();
      await t.tap(find.text('Quartier Général'));
      await t.pumpAndSettle();
      await t.tap(find.text('Améliorer'));
      await t.pumpAndSettle();

      expect(find.byType(VictoryScreen), findsNothing);
      expect(game.status, GameStatus.playing);
    });

    testWidgets('upgrading kernel to 9 does not trigger victory', (t) async {
      _setLargeScreen(t);
      addTearDown(() { t.view.resetPhysicalSize(); t.view.resetDevicePixelRatio(); });
      final game = _makeKernelGame(kernelLevel: 8);
      await upgradeKernel(t, game);

      expect(find.byType(VictoryScreen), findsNothing);
      expect(game.status, GameStatus.playing);
    });

    testWidgets('upgrading kernel to 10 navigates to victory', (t) async {
      _setLargeScreen(t);
      addTearDown(() { t.view.resetPhysicalSize(); t.view.resetDevicePixelRatio(); });
      final game = _makeKernelGame(kernelLevel: 9);
      await upgradeKernel(t, game);

      expect(find.byType(VictoryScreen), findsOneWidget);
      expect(game.status, GameStatus.victory);
    });

    testWidgets('continue sets freePlay status', (t) async {
      _setLargeScreen(t);
      addTearDown(() { t.view.resetPhysicalSize(); t.view.resetDevicePixelRatio(); });
      final game = _makeKernelGame(kernelLevel: 9);
      await upgradeKernel(t, game);

      await t.tap(find.text('Continuer en mode libre'));
      await t.pumpAndSettle();

      expect(game.status, GameStatus.freePlay);
      expect(find.byType(VictoryScreen), findsNothing);
    });

    testWidgets('return to menu navigates to main menu', (t) async {
      _setLargeScreen(t);
      addTearDown(() { t.view.resetPhysicalSize(); t.view.resetDevicePixelRatio(); });
      final game = _makeKernelGame(kernelLevel: 9);
      await upgradeKernel(t, game);

      await t.tap(find.text('Retour au menu'));
      await t.pumpAndSettle();

      expect(find.byType(MainMenuScreen), findsOneWidget);
    });
  });
}

import 'package:abyss/data/game_repository.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/map/game_map.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/map/map_cell.dart';
import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/domain/unit/unit.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/screens/game/game_screen_map_actions.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/map/game_map_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_game_repository.dart';

/// Side of the square test maps built by [plainMap].
const int harnessMapSize = 10;

/// A plain map where [overrides] replace the cells at given positions.
GameMap plainMap([Map<GridPosition, MapCell> overrides = const {}]) {
  final cells = List.generate(
    harnessMapSize * harnessMapSize,
    (i) =>
        overrides[GridPosition(x: i % harnessMapSize, y: i ~/ harnessMapSize)] ??
        MapCell(terrain: TerrainType.plain),
  );
  return GameMap(
    width: harnessMapSize,
    height: harnessMapSize,
    cells: cells,
    seed: 1,
  );
}

/// Every position of a [harnessMapSize] map.
List<GridPosition> allPositions() => [
      for (var y = 0; y < harnessMapSize; y++)
        for (var x = 0; x < harnessMapSize; x++) GridPosition(x: x, y: y),
    ];

/// A single-player game on [map] (level 1) with base at (5, 5).
Game harnessGame(
  GameMap map, {
  List<GridPosition>? revealed,
  int scouts = 0,
}) {
  final player = Player(
    name: 'Nemo',
    baseX: 5,
    baseY: 5,
    revealedCellsPerLevel: {1: revealed ?? allPositions()},
    unitsPerLevel: {
      1: {UnitType.scout: Unit(type: UnitType.scout, count: scouts)},
    },
  );
  return Game.singlePlayer(player)..levels = {1: map};
}

/// Hosts [buildMapTab] for [game] in a themed app.
Widget mapTabHost(
  Game game, {
  GameRepository? repository,
  VoidCallback? onChanged,
  ValueChanged<int>? onLevelSelected,
}) {
  return MaterialApp(
    theme: AbyssTheme.create(),
    home: Scaffold(
      body: Builder(
        builder: (context) => buildMapTab(
          context,
          game,
          repository ?? FakeGameRepository(),
          currentLevel: 1,
          unlockedLevels: game.levels.keys.toSet(),
          onLevelSelected: onLevelSelected ?? (_) {},
          onChanged: onChanged ?? () {},
        ),
      ),
    ),
  );
}

/// Simulates a tap on the map cell ([x], [y]) and settles.
Future<void> tapMapCell(WidgetTester tester, int x, int y) async {
  tester.widget<GameMapView>(find.byType(GameMapView)).onCellTap!(x, y);
  await tester.pumpAndSettle();
}

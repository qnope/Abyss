import 'dart:math';

import 'package:abyss/domain/action/action_executor.dart';
import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/faction/faction_turn.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/game_factory.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/game_map.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/map/map_cell.dart';
import 'package:abyss/domain/map/reveal_area_calculator.dart';
import 'package:abyss/domain/map/transition_base_type.dart';
import 'package:abyss/domain/script/script_turn.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/domain/volcano/kernel_garrison.dart';

/// A game against [factions] factions (6 give 32-cell maps) where the
/// first faction scouts; it holds nothing yet and has no scout anywhere.
class DeepScouts {
  final Game game;

  DeepScouts({int factions = 6, int mapSeed = 7})
    : game = GameFactory.newGame(
        playerName: 'Nemo',
        mapSeed: mapSeed,
        factionCount: factions,
      ) {
    put(1, 0);
  }

  Player get faction => game.players[game.factions[0].id]!;

  ScriptTurn turn() => FactionTurn(
    game: game,
    player: faction,
    executor: ActionExecutor(),
    seeds: Random(3),
  );

  /// Puts [n] scouts on [level] of the faction.
  void put(int level, int n) =>
      KernelGarrison.stockAt(faction, level)[UnitType.scout]!.count = n;

  /// Scouts of the faction on [level]; a level it never reached has none.
  int scouts(int level) =>
      faction.unitsPerLevel[level]?[UnitType.scout]?.count ?? 0;

  /// Gives the faction the first post of [kind] and its passage building;
  /// a Cheminée means it already stands on level 2, so a descent there
  /// keeps its fog.
  void hold(TransitionBaseType kind) {
    final int level = kind == TransitionBaseType.faille ? 1 : 2;
    put(level, scouts(level));
    final GameMap map = game.levels[level]!;
    final GridPosition at = cells(level, (c) => c.transitionBase?.type == kind)
        .first;
    map.cellAt(at.x, at.y).transitionBase!.capturedBy = faction.id;
    faction.addRevealedCell(level, at);
    final BuildingType passage = kind == TransitionBaseType.faille
        ? BuildingType.descentModule
        : BuildingType.pressureCapsule;
    faction.buildings[passage] = Building(type: passage, level: 1);
  }

  /// Cells of [level] whose content passes [test].
  List<GridPosition> cells(int level, bool Function(MapCell) test) {
    final GameMap map = game.levels[level]!;
    return <GridPosition>[
      for (var y = 0; y < map.height; y++)
        for (var x = 0; x < map.width; x++)
          if (test(map.cellAt(x, y))) GridPosition(x: x, y: y),
    ];
  }

  /// The cells of the volcanic kernel on level 3.
  List<GridPosition> get kernel =>
      cells(3, (c) => c.content == CellContentType.volcanicKernel);

  /// Reveals the [side] x [side] square around [p] on [level].
  void reveal(int level, GridPosition p, {int side = 3}) {
    final GameMap map = game.levels[level]!;
    for (final GridPosition c in RevealAreaCalculator.cellsToReveal(
      targetX: p.x,
      targetY: p.y,
      side: side,
      mapWidth: map.width,
      mapHeight: map.height,
    )) {
      faction.addRevealedCell(level, c);
    }
  }

  /// Targets of the faction's pending explorations on [level].
  List<GridPosition> targets(int level) => <GridPosition>[
    for (final o in faction.pendingExplorations)
      if (o.level == level) o.target,
  ];
}

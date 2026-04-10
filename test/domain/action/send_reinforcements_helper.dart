import 'package:abyss/domain/action/send_reinforcements_action.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/game_map.dart';
import 'package:abyss/domain/map/map_cell.dart';
import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/domain/map/transition_base.dart';
import 'package:abyss/domain/map/transition_base_type.dart';
import 'package:abyss/domain/unit/unit.dart';
import 'package:abyss/domain/unit/unit_type.dart';

GameMap buildReinforcementMap({TransitionBase? transitionBase}) {
  final cells = <MapCell>[];
  for (var i = 0; i < 25; i++) {
    final isCenter = i == 12;
    cells.add(MapCell(
      terrain: TerrainType.plain,
      content: isCenter && transitionBase != null
          ? CellContentType.transitionBase
          : CellContentType.empty,
      transitionBase: isCenter ? transitionBase : null,
    ));
  }
  return GameMap(width: 5, height: 5, cells: cells, seed: 1);
}

({Game game, Player player}) createReinforcementScenario({
  int scoutCount = 5,
  String capturedBy = 'p1',
  bool withTargetLevel = true,
}) {
  final base = TransitionBase(
    type: TransitionBaseType.faille,
    name: 'Faille Alpha',
    capturedBy: capturedBy,
  );

  final player = Player(
    id: 'p1',
    name: 'Test',
    unitsPerLevel: {
      1: {
        for (final t in UnitType.values)
          t: Unit(
            type: t,
            count: t == UnitType.scout ? scoutCount : 0,
          ),
      },
    },
  );

  final levels = <int, GameMap>{
    1: buildReinforcementMap(transitionBase: base),
  };
  if (withTargetLevel) {
    levels[2] = buildReinforcementMap();
  }

  final game = Game(
    humanPlayerId: player.id,
    players: {player.id: player},
    levels: levels,
  );

  return (game: game, player: player);
}

SendReinforcementsAction createReinforcementAction({
  Map<UnitType, int>? units,
}) {
  return SendReinforcementsAction(
    transitionX: 2,
    transitionY: 2,
    fromLevel: 1,
    selectedUnits: units ?? {UnitType.scout: 3},
  );
}

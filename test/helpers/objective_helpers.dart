import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/objective/objective_catalog.dart';
import 'package:abyss/domain/objective/objective_id.dart';
import 'package:abyss/domain/unit/unit.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import 'map_tab_harness.dart';

/// A fresh game on a plain [harnessMapSize] map, its player built as a new
/// game builds it: base at (5, 5), only the area around it revealed.
Game objectiveGame() {
  final player = Player.withBase(
    name: 'Nemo',
    baseX: 5,
    baseY: 5,
    mapWidth: harnessMapSize,
    mapHeight: harnessMapSize,
  );
  return Game.singlePlayer(player)..levels = {1: plainMap()};
}

/// Sets the [type] building of [player] to [level].
void setBuilding(Player player, BuildingType type, int level) =>
    player.buildings[type]!.level = level;

/// Gives [player] [count] units of [type] on [level].
void setUnits(Player player, UnitType type, int count, {int level = 1}) =>
    player.unitsPerLevel.putIfAbsent(level, () => {})[type] = Unit(
      type: type,
      count: count,
    );

/// Checks the progress of objective [id] on the human player of [game].
void expectProgress(Game game, ObjectiveId id, int current, int target) {
  final progress = ObjectiveCatalog.byId(id).progressOf(game, game.humanPlayer);
  expect(
    (progress.current, progress.target, progress.isDone),
    (current, target, current >= target),
    reason: id.name,
  );
}

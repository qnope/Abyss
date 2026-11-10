import '../../map/exploration_order.dart';
import '../../map/game_map.dart';
import '../../map/grid_position.dart';
import '../../map/map_cell.dart';
import '../../map/monster_lair.dart';
import '../../map/reinforcement_order.dart';
import '../../map/transition_base.dart';
import '../class_snapshot.dart';
import '../snapshot_values.dart';

/// Snapshots of the maps and of what moves on them.
abstract final class MapSnapshots {
  static final ClassSnapshot<GridPosition> position =
      ClassSnapshot<GridPosition>('GridPosition', {
        'x': (p, _) => p.x,
        'y': (p, _) => p.y,
      });

  static final ClassSnapshot<MonsterLair> lair =
      ClassSnapshot<MonsterLair>('MonsterLair', {
        'difficulty': (l, _) => l.difficulty.name,
        'unitCount': (l, _) => l.unitCount,
        'family': (l, _) => l.family?.name,
        'secondFamily': (l, _) => l.secondFamily?.name,
        'secondCount': (l, _) => l.secondCount,
      });

  static final ClassSnapshot<TransitionBase> transitionBase =
      ClassSnapshot<TransitionBase>('TransitionBase', {
        'type': (b, _) => b.type.name,
        'name': (b, _) => b.name,
        'capturedBy': (b, ids) => ids.orNull(b.capturedBy),
      });

  static final ClassSnapshot<MapCell> cell = ClassSnapshot<MapCell>('MapCell', {
    'terrain': (c, _) => c.terrain.name,
    'content': (c, _) => c.content.name,
    'lair': (c, ids) => lair.orNull(c.lair, ids),
    'collectedBy': (c, ids) => ids.orNull(c.collectedBy),
    'transitionBase': (c, ids) => transitionBase.orNull(c.transitionBase, ids),
    'passageName': (c, _) => c.passageName,
  });

  /// The cells are in row order: the cell at (x, y) is `y * width + x`.
  static final ClassSnapshot<GameMap> gameMap =
      ClassSnapshot<GameMap>('GameMap', {
        'width': (m, _) => m.width,
        'height': (m, _) => m.height,
        'cells': (m, ids) => cell.listOf(m.cells, ids),
        'seed': (m, _) => m.seed,
      });

  static final ClassSnapshot<ExplorationOrder> exploration =
      ClassSnapshot<ExplorationOrder>('ExplorationOrder', {
        'target': (o, ids) => position.of(o.target, ids),
        'level': (o, _) => o.level,
      });

  static final ClassSnapshot<ReinforcementOrder> reinforcement =
      ClassSnapshot<ReinforcementOrder>('ReinforcementOrder', {
        'fromLevel': (o, _) => o.fromLevel,
        'toLevel': (o, _) => o.toLevel,
        'units': (o, _) => SnapshotValues.counts(o.units),
        'departTurn': (o, _) => o.departTurn,
        'arrivalPoint': (o, ids) => position.of(o.arrivalPoint, ids),
      });
}

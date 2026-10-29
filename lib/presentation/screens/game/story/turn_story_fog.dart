import '../../../../domain/game/game.dart';
import '../../../../domain/map/cell_content_type.dart';
import '../../../../domain/map/map_cell.dart';
import '../../../widgets/map/effects/story/map_fog_lift.dart';
import '../../../widgets/map/map_scatter.dart';
import 'story_chapter.dart';
import 'turn_story_snapshot.dart';

/// The fog lifting from the cells seen during the turn of [game], on the
/// level where the most were seen, `null` when none was.
///
/// The map centres on the first scout whose exploration ended there, or
/// else on the seen cell nearest the middle of them all.
StoryChapter? fogLiftChapter(Game game, TurnStorySnapshot before) {
  final human = game.humanPlayer;
  int? level;
  var seen = <(int, int)>{};
  for (final candidate in game.levels.keys.toList()..sort()) {
    final cells = before.newlySeen(human, candidate);
    if (cells.length > seen.length) (level, seen) = (candidate, cells);
  }
  final map = game.levels[level];
  if (level == null || map == null) return null;
  final scouts = before.scoutsGone(human, level).where(seen.contains).toSet();
  return StoryChapter(
    level: level,
    effect: MapFogLift(
      cells: {
        for (final (x, y) in seen)
          (x, y): floorTileOf(map.cellAt(x, y).terrain, (x, y)),
      },
      scouts: scouts,
      beacons: {
        for (final (x, y) in seen)
          if (_isBeacon(map.cellAt(x, y))) (x, y),
      },
      focus: scouts.isNotEmpty ? scouts.first : _middleOf(seen),
    ),
  );
}

/// Whether [cell] shows through the fog: a wreck not searched yet.
bool _isBeacon(MapCell cell) =>
    cell.content == CellContentType.wreck && !cell.isCollected;

/// The cell of [cells] nearest their middle.
(int, int) _middleOf(Set<(int, int)> cells) {
  final x = cells.fold(0.0, (sum, c) => sum + c.$1) / cells.length;
  final y = cells.fold(0.0, (sum, c) => sum + c.$2) / cells.length;
  double away((int, int) c) => (c.$1 - x) * (c.$1 - x) + (c.$2 - y) * (c.$2 - y);
  return cells.reduce((a, b) => away(b) < away(a) ? b : a);
}

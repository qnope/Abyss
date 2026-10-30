import '../map_cell_visual.dart';
import '../map_content_spot.dart';
import '../map_flat_contents.dart';
import '../map_projection.dart';
import '../map_standing_hit.dart';
import 'decor_scatter.dart';

export 'decor_scatter.dart';

/// The decor standing between the cells of [visuals], a map [columns]
/// cells wide, scattered by [salt] (the map's level) as [scatterDecor]
/// does.
///
/// No decor touches a cell holding a content seen on the map (the
/// volcano's whole block included), reaches into a content's tap box or
/// the diamond of a hole lying flat, nor, standing in front of a
/// content, into anything it draws: its sprite as it moves, its shadow,
/// its ring. So a decor is never taken for a content, and none standing
/// in front of a content is drawn under it, though the still map draws
/// every decor before the contents. Decor among hidden cells lies under
/// the fog; what hides there plays no part, so it gives nothing away.
List<MapDecor> mapDecorOf(
  List<MapCellVisual> visuals,
  int columns, {
  required int salt,
}) {
  final rows = columns == 0 ? 0 : visuals.length ~/ columns;
  final blocked = List.filled(visuals.length, false);
  final keepOut = <DecorKeepOut>[];
  for (var i = 0; i < visuals.length; i++) {
    final visual = visuals[i];
    if (visual.contentSprite == null) continue;
    final (x, y) = (i % columns, i ~/ columns);
    final span = visual.contentSpan;
    for (var dy = 0; dy < span && y + dy < rows; dy++) {
      for (var dx = 0; dx < span && x + dx < columns; dx++) {
        blocked[(y + dy) * columns + x + dx] = true;
      }
    }
    keepOut.add(visual.liesFlat
        ? DecorKeepOut.box(MapProjection.floorOf((x, y)))
        : _keepOutOf(MapContentSpot.of(visual, i, columns)));
  }
  return scatterDecor(
    columns: columns,
    rows: rows,
    salt: salt,
    isBlocked: (x, y) => blocked[y * columns + x],
    isHidden: (x, y) => !visuals[y * columns + x].revealed,
    keepOut: keepOut,
  );
}

/// The way of a content standing at [spot]: its tap box; and what it
/// draws but its glow, which may light a decor: its sprite as it moves,
/// its shadow and its ring; in front of the middle of its floor.
DecorKeepOut _keepOutOf(MapContentSpot spot) => DecorKeepOut(
      core: standingHitBox(spot.area),
      drawn: spot.area
          .inflate(MapContentSpot.motionMargin * spot.area.width)
          .expandToInclude(spot.shadow)
          .expandToInclude(spot.ring),
      depth: spot.ring.center.dy,
    );

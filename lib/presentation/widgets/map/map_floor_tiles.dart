import 'package:flutter/painting.dart';

import '../../theme/abyss_colors.dart';
import '../common/atlas_mesh.dart';
import 'map_content_drawer.dart';
import 'map_projection.dart';
import 'map_sprites.dart';

/// Lays the floor tiles of a still map, in projection coordinates, each
/// in its box ([tileOf]) as its bitmap drawn whole there would look.
///
/// The tiles packed in the [MapSprites.floor] atlas go into one mesh of
/// diamonds, drawn in a single call ([flush]) in the order laid, so the
/// bevels along their seams overlap as bitmaps drawn in turn would: no
/// transparent corner is drawn. A tile not packed is drawn as a bitmap
/// in turn, one not loaded yet as a plain diamond.
class MapFloorTiles {
  /// How far a floor tile is drawn past its box, so that neighbours
  /// overlap and no seam shows between them.
  static const bleed = 1.5;

  /// How much larger than the diamond inscribed in its box a tile is
  /// laid: its sprite's bevels reach just past that diamond.
  static const reach = 1.06;

  final MapSprites? sprites;

  /// How the tiles are sampled: smoothly, with mipmaps, by default.
  final FilterQuality filterQuality;
  final AtlasMesh<String>? _mesh;
  final _drawer = MapContentDrawer(null);
  final Paint _bitmap;
  final _fallback = Paint()..color = AbyssColors.plainBlue;

  MapFloorTiles(this.sprites, {this.filterQuality = FilterQuality.medium})
      : _mesh = sprites == null ? null : AtlasMesh(sprites.floor),
        _bitmap = Paint()..filterQuality = filterQuality;

  /// The box the floor tile of [cell] is drawn in: its tile box, a hair
  /// larger.
  static Rect tileOf((int, int) cell) => Rect.fromCenter(
        center: MapProjection.centreOf(cell),
        width: MapProjection.tileWidth + 2 * bleed,
        height: MapProjection.tileHeight + bleed,
      );

  /// Lays the [tile] of [cell], drawing on [canvas] what the mesh lacks.
  void add(Canvas canvas, (int, int) cell, String tile) {
    final box = tileOf(cell);
    if (_mesh?.addDiamond(tile, box, reach: reach) ?? false) return;
    flush(canvas);
    final image = sprites?.svg(tile);
    image == null
        ? canvas.drawPath(MapProjection.diamondOf(cell), _fallback)
        : _drawer.drawSprite(canvas, image, box, _bitmap);
  }

  /// Draws the tiles laid so far.
  void flush(Canvas canvas) =>
      _mesh?.flush(canvas, filterQuality: filterQuality);
}

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/presentation/extensions/terrain_type_extensions.dart';
import 'package:abyss/presentation/theme/abyss_colors.dart';
import 'package:abyss/presentation/widgets/map/map_content_drawer.dart';
import 'package:abyss/presentation/widgets/map/map_floor_tiles.dart';
import 'package:abyss/presentation/widgets/map/map_projection.dart';
import 'package:abyss/presentation/widgets/map/map_sprites.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final tiles = TerrainType.plain.tileSvgPaths;
  late MapSprites sprites;
  setUpAll(() async => sprites = await MapSprites.load());

  /// The tile of each cell of a 4 by 4 map, mixed.
  final floor = {
    for (var y = 0; y < 4; y++)
      for (var x = 0; x < 4; x++) (x, y): tiles[(x * 7 + y * 5) % 3],
  };

  void lay(Canvas canvas, MapSprites? sprites, Map<(int, int), String> of,
      {FilterQuality quality = FilterQuality.medium}) {
    final layer = MapFloorTiles(sprites, filterQuality: quality);
    of.forEach((cell, tile) => layer.add(canvas, cell, tile));
    layer.flush(canvas);
  }

  /// The pixels of [draw] over the map's floor, at [scale].
  Future<Uint8List> pixels(double scale, void Function(Canvas) draw) async {
    final box = MapProjection.outlineOf(4, 4);
    final (left, width) = (box[3].dx - 4, box[1].dx - box[3].dx + 8);
    final height = box[2].dy + 8;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder)
      ..scale(scale)
      ..translate(-left, 4);
    draw(canvas);
    final image = await recorder
        .endRecording()
        .toImage((width * scale).ceil(), (height * scale).ceil());
    final bytes = await image.toByteData();
    image.dispose();
    return bytes!.buffer.asUint8List();
  }

  // Sampled without mipmaps: the test engine's raster backend leaves them
  // out of a mesh, where GPUs pick them per pixel as for a bitmap.
  test('looks as each tile drawn whole as a bitmap, in turn, seams '
      'included, from up close or far', () async {
    const low = FilterQuality.low;
    final paint = Paint()..filterQuality = low;
    final drawer = MapContentDrawer(sprites);
    for (final scale in [0.6, 1.0, 2.5]) {
      final expected = await pixels(scale, (canvas) {
        floor.forEach((cell, tile) => drawer.drawSprite(
            canvas, sprites.svg(tile), MapFloorTiles.tileOf(cell), paint));
      });
      final actual =
          await pixels(scale, (c) => lay(c, sprites, floor, quality: low));
      var off = 0, worst = 0;
      for (var i = 0; i < expected.length; i++) {
        final d = (expected[i] - actual[i]).abs();
        if (d > 2) off++;
        if (d > worst) worst = d;
      }
      expect(off / expected.length, lessThan(0.002), reason: 'at $scale');
      expect(worst, lessThan(80), reason: 'at $scale');
    }
  });

  test('lays every tile in one draw, however many', () {
    expect((Canvas canvas) => lay(canvas, sprites, floor),
        paints..something((method, _) => method == #drawVertices));
    expect((Canvas canvas) => lay(canvas, sprites, floor),
        paintsExactlyCountTimes(#drawVertices, 1));
    expect((Canvas canvas) => lay(canvas, sprites, floor),
        paintsExactlyCountTimes(#drawImageRect, 0));
  });

  test('draws a tile not packed as a bitmap, in turn, and a tile not '
      'loaded yet as a plain diamond', () {
    const odd = 'assets/icons/terrain/plain.svg';
    final cells = {(0, 0): tiles[0], (1, 0): odd, (0, 1): tiles[1]};
    expect(
      (Canvas canvas) => lay(canvas, sprites, cells),
      paints
        ..something((method, _) => method == #drawVertices)
        ..drawImageRect(
            image: sprites.svg(odd), destination: MapFloorTiles.tileOf((1, 0)))
        ..something((method, _) => method == #drawVertices),
    );
    expect(
      (Canvas canvas) => lay(canvas, null, {(0, 0): tiles[0]}),
      paints..path(color: AbyssColors.plainBlue),
    );
  });
}

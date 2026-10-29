import 'package:abyss/presentation/widgets/map/map_cell_visual.dart';
import 'package:abyss/presentation/widgets/map/map_painter.dart';
import 'package:abyss/presentation/widgets/map/map_projection.dart';
import 'package:abyss/presentation/widgets/map/map_sprites.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

typedef PaintCallback = void Function(Canvas canvas);

/// Paints the cells of [visuals], two per row, with the real sprites.
Future<PaintCallback> painterOf(
  WidgetTester tester,
  List<MapCellVisual> visuals,
) async {
  final sprites = await tester.runAsync(MapSprites.load);
  final painter = MapPainter(visuals: visuals, columns: 2, sprites: sprites);
  return (Canvas canvas) =>
      painter.paint(canvas, MapProjection.sizeOf(2, visuals.length ~/ 2));
}

import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/presentation/extensions/terrain_type_extensions.dart';
import 'package:abyss/presentation/widgets/map/map_cell_visual.dart';
import 'package:abyss/presentation/widgets/map/map_floor.dart';
import 'package:abyss/presentation/widgets/map/map_painter.dart';
import 'package:abyss/presentation/widgets/map/map_projection.dart';
import 'package:abyss/presentation/widgets/map/slab/map_slab_layer.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/background_rasters.dart';

void main() {
  final tile = TerrainType.plain.tileSvgPaths.first;
  List<MapCellVisual> cells({int seen = 1, bool pending = false}) => [
        for (var i = 0; i < 4; i++)
          MapCellVisual(terrainSprite: tile, revealed: i < seen,
              pending: pending && i == 3),
      ];

  final transform = ValueNotifier(Matrix4.identity());
  const viewport = Size(40, 20);

  Future<void> pump(WidgetTester tester, List<MapCellVisual> visuals) =>
      tester.pumpWidget(Align(
        alignment: Alignment.topLeft,
        child: MapFloor(visuals: visuals, columns: 2, level: 3,
            transform: transform, viewport: viewport),
      ));

  MapPainter painterOf(WidgetTester tester) => tester
      .widget<CustomPaint>(find.byWidgetPredicate(
          (w) => w is CustomPaint && w.painter is MapPainter))
      .painter! as MapPainter;

  /// Lets the fog's bitmap under way be rasterized, then painted.
  Future<void> settle(WidgetTester tester) => settleRasters(
      tester, () => painterOf(tester).fogRaster!.image != null);

  testWidgets('paints the still floor of the map in its own boundary', (
    tester,
  ) async {
    await pump(tester, cells());
    final painter = painterOf(tester);
    expect(painter.columns, 2);
    expect(painter.decorSalt, 3);
    expect(painter.slab, isFalse, reason: 'painted on its own');
    expect(tester.getSize(find.byType(MapFloor)),
        MapProjection.sizeOf(2, 2));
    expect(find.descendant(of: find.byType(MapFloor),
        matching: find.byType(RepaintBoundary, skipOffstage: false),
        skipOffstage: false),
        findsNWidgets(2));
  });

  testWidgets('stands the map on its slab, over the rest of the floor', (
    tester,
  ) async {
    await pump(tester, cells());
    final widgets = tester.allWidgets.toList();
    final floor = widgets.indexWhere(
        (w) => w is CustomPaint && w.painter is MapPainter);
    final slab = tester.widget<MapSlabLayer>(find.byType(MapSlabLayer));
    expect(widgets.indexOf(slab), greaterThan(floor));
    expect((slab.columns, slab.rows, slab.salt), (2, 2, 3));
    expect(slab.transform, same(transform));
    expect(slab.viewport, viewport);
  });

  testWidgets('never holds a frame for the bitmap of its fog: the fog is '
      'drawn live until it is ready, then from it', (tester) async {
    bool replay(Symbol method, List<dynamic> args) => method == #drawPicture;
    final floor = find.byWidgetPredicate(
        (w) => w is CustomPaint && w.painter is MapPainter);
    await pump(tester, cells());
    final raster = painterOf(tester).fogRaster!;
    expect(raster.image, isNull);
    expect(floor, paints..something(replay));
    await settle(tester);
    expect(raster.image, isNotNull);
    expect(floor, paints..drawImageRect(image: raster.image));
    expect(floor, isNot(paints..something(replay)));
    // Other cells hidden: live again, the old bitmap gone at once.
    final old = raster.image!;
    await pump(tester, cells(seen: 2));
    expect(old.debugDisposed, isTrue);
    expect(floor, paints..something(replay));
    await settle(tester);
    expect(floor, paints..drawImageRect(image: raster.image));
  });

  testWidgets('keeps the bitmap of its fog across rebuilds while the same '
      'cells are hidden', (tester) async {
    await pump(tester, cells());
    await settle(tester);
    final raster = painterOf(tester).fogRaster!;
    final fog = raster.image!;
    await pump(tester, cells(pending: true));
    expect(painterOf(tester).fogRaster, same(raster));
    expect(raster.image, same(fog));
    await pump(tester, cells(seen: 2));
    expect(fog.debugDisposed, isTrue);
    await settle(tester);
    expect(raster.image, isNot(same(fog)));
  });

  testWidgets('disposes the bitmap of its fog when it goes away', (
    tester,
  ) async {
    await pump(tester, cells());
    await settle(tester);
    final fog = painterOf(tester).fogRaster!.image!;
    await tester.pumpWidget(const SizedBox());
    expect(fog.debugDisposed, isTrue);
  });
}

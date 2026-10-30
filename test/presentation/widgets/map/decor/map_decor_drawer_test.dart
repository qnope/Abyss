import 'dart:typed_data';
import 'dart:ui';

import 'package:abyss/presentation/widgets/map/decor/decor_kind.dart';
import 'package:abyss/presentation/widgets/map/decor/map_decor.dart';
import 'package:abyss/presentation/widgets/map/decor/map_decor_drawer.dart';
import 'package:abyss/presentation/widgets/map/map_sprites.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final rock = MapDecor(
      sprite: SeabedDecor.rock.svgPath, foot: const Offset(10, 20), size: 40);
  final coral = MapDecor(
      sprite: SeabedDecor.coralTeal.svgPath,
      foot: const Offset(60, 50),
      size: 50);

  testWidgets('without an atlas, draws every shadow, then every decor, in '
      'order', (tester) async {
    final sprites = (await tester.runAsync(MapSprites.load))!;
    final drawer =
        MapDecorDrawer(imageOf: sprites.svg, shadow: sprites.shadow);
    expect(
      (Canvas canvas) => drawer.draw(canvas, [rock, coral]),
      paints
        ..drawImageRect(
            image: sprites.shadow, destination: MapDecorDrawer.shadowOf(rock))
        ..drawImageRect(
            image: sprites.shadow, destination: MapDecorDrawer.shadowOf(coral))
        ..drawImageRect(image: sprites.svg(rock.sprite), destination: rock.box)
        ..drawImageRect(
            image: sprites.svg(coral.sprite), destination: coral.box),
    );
  });

  testWidgets('from an atlas, lays every shadow in one draw, then every '
      'decor in another, looking the same', (tester) async {
    final sprites = (await tester.runAsync(MapSprites.load))!;
    final decor = [
      for (var i = 0; i < 12; i++)
        MapDecor(
            sprite: SeabedDecor.all[i % SeabedDecor.all.length].svgPath,
            foot: Offset(30.0 + 23 * (i % 4), 40.0 + 9 * i),
            size: 30.0 + 3 * i),
    ];
    MapDecorDrawer drawer({required bool packed}) => MapDecorDrawer(
        imageOf: sprites.svg,
        shadow: sprites.shadow,
        atlas: packed ? sprites.floor : null,
        shadowSprite: MapSprites.shadowSprite,
        filterQuality: FilterQuality.low);
    expect((Canvas canvas) => drawer(packed: true).draw(canvas, decor),
        paintsExactlyCountTimes(#drawVertices, 2));
    expect((Canvas canvas) => drawer(packed: true).draw(canvas, decor),
        paintsExactlyCountTimes(#drawImageRect, 0));
    Future<Uint8List> pixels(MapDecorDrawer drawer) async {
      final recorder = PictureRecorder();
      drawer.draw(Canvas(recorder)..scale(2), decor);
      final image = await recorder.endRecording().toImage(300, 340);
      return (await image.toByteData())!.buffer.asUint8List();
    }

    final (expected, actual) = (await tester.runAsync(() async => (
          await pixels(drawer(packed: false)),
          await pixels(drawer(packed: true)),
        )))!;
    var off = 0;
    for (var i = 0; i < expected.length; i++) {
      if ((expected[i] - actual[i]).abs() > 2) off++;
    }
    expect(off / expected.length, lessThan(0.002));
  });

  testWidgets('lays a small shadow at the foot, falling away from the light',
      (tester) async {
    final shadow = MapDecorDrawer.shadowOf(coral);
    expect(shadow.width, lessThan(coral.size));
    expect(shadow.height, shadow.width / 2);
    expect(shadow.center.dx, greaterThan(coral.foot.dx));
    expect(shadow.center.dy, greaterThan(coral.foot.dy));
    expect(shadow.contains(coral.foot), isTrue);
  });

  testWidgets('skips what is not loaded', (tester) async {
    final drawer = MapDecorDrawer(imageOf: (_) => null);
    expect((Canvas canvas) => drawer.draw(canvas, [rock, coral]),
        paintsExactlyCountTimes(#drawImageRect, 0));
  });
}

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

  testWidgets('draws every shadow, then every decor, in order', (
    tester,
  ) async {
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

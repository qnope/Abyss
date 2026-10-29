import 'package:abyss/presentation/widgets/ambience/ambient_motion.dart';
import 'package:abyss/presentation/widgets/map/map_cell_visual.dart';
import 'package:abyss/presentation/widgets/map/map_content_fade.dart';
import 'package:abyss/presentation/widgets/map/map_content_spot.dart';
import 'package:abyss/presentation/widgets/map/map_projection.dart';
import 'package:abyss/presentation/widgets/map/map_sprites.dart';
import 'package:abyss/presentation/widgets/map/map_standing_painter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'map_standing_probe.dart';

void main() {
  /// A row of four cells: two bobbing, one still, one pulsing.
  final row = [
    standingCell(AmbientMotion.bob),
    standingCell(AmbientMotion.bob),
    standingCell(AmbientMotion.still),
    standingCell(AmbientMotion.pulse, glow: MapGlow.post),
  ];
  late MapContentFade fade;
  setUp(() => fade = MapContentFade());
  tearDown(() => fade.dispose());

  MapStandingPainter painterOf({MapSprites? sprites}) =>
      standingPainterOf(row, columns: 4, sprites: sprites, fade: fade);

  testWidgets('hides the contents of the cells faded out, the others whole', (
    tester,
  ) async {
    final sprites = (await tester.runAsync(MapSprites.load))!;
    fade.fade(const {(1, 0), (6, 6)}, 0);
    final paint = paintOf(painterOf(sprites: sprites));
    // Nine images in all, less the shadow and the sprite of (1, 0).
    expect(paint, paintsExactlyCountTimes(#drawImageRect, 7));
    expect(paint, paintsExactlyCountTimes(#saveLayer, 0));
    expect(
      paint,
      isNot(paints
        ..drawImageRect(
            destination: MapContentSpot.of(row[1], 1, 4).shadow)),
    );
    expect(
      paint,
      isNot(paints
        ..drawImageRect(destination: MapProjection.standingOf((1, 0)))),
    );
  });

  testWidgets('draws a content fading in apart, at the fade\'s opacity, '
      'its floor then its sprite', (tester) async {
    final sprites = (await tester.runAsync(MapSprites.load))!;
    fade.fade(const {(1, 0)}, 0.4);
    final paint = paintOf(painterOf(sprites: sprites));
    expect(paint, paintsExactlyCountTimes(#drawImageRect, 9));
    expect(paint, paintsExactlyCountTimes(#saveLayer, 2));
    final bounds = MapContentSpot.of(row[1], 1, 4).bounds;
    expect(
      paint,
      paints
        ..something((method, arguments) {
          if (method != #saveLayer) return false;
          final opacity = (arguments[1] as Paint).color.a;
          return arguments[0] == bounds && (opacity - 0.4).abs() < 0.01;
        })
        ..drawImageRect(destination: MapContentSpot.of(row[1], 1, 4).shadow)
        ..restore(),
    );
  });

  testWidgets('draws every content whole once the fade is over', (
    tester,
  ) async {
    final sprites = (await tester.runAsync(MapSprites.load))!;
    fade.fade(const {(1, 0)}, 1);
    final paint = paintOf(painterOf(sprites: sprites));
    expect(paint, paintsExactlyCountTimes(#drawImageRect, 9));
    expect(paint, paintsExactlyCountTimes(#saveLayer, 0));
  });

  test('repaints as the fade changes, even when nothing moves', () {
    final still = standingPainterOf([row[2], row[2]],
        columns: 2, fade: fade);
    var heard = 0;
    still.addListener(() => heard++);
    fade.fade(const {(0, 0)}, 0.5);
    fade.clear();
    expect(heard, 2);
  });

  test('a rebuild with another fade is repainted', () {
    final other = MapContentFade();
    addTearDown(other.dispose);
    final clock = ValueNotifier(0.0);
    final transform = TransformationController();
    MapStandingPainter build(MapContentFade fade) => standingPainterOf(row,
        columns: 4, clock: clock, transform: transform, fade: fade);
    expect(build(fade).shouldRepaint(build(fade)), isFalse);
    expect(build(fade).shouldRepaint(build(other)), isTrue);
  });
}

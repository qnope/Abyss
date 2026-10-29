import 'package:abyss/presentation/widgets/ambience/ambient_motion.dart';
import 'package:abyss/presentation/widgets/map/map_cell_visual.dart';
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

  MapStandingPainter painterOf(
    List<MapCellVisual> visuals, {
    ValueNotifier<double>? clock,
    TransformationController? transform,
    Size? viewport,
  }) =>
      standingPainterOf(visuals,
          columns: 4, clock: clock, transform: transform, viewport: viewport);

  test('repaints when the clock ticks or the map is panned', () {
    final clock = ValueNotifier(0.0);
    final transform = TransformationController();
    final painter = painterOf(row, clock: clock, transform: transform);
    var heard = 0;
    painter.addListener(() => heard++);
    clock.value = 0.5;
    transform.value = Matrix4.translationValues(-10, 0, 0);
    expect(heard, 2);
  });

  test('a map where nothing moves is not repainted by the clock', () {
    final clock = ValueNotifier(0.0);
    final transform = TransformationController();
    final painter = painterOf([row[2], row[2]],
        clock: clock, transform: transform);
    var heard = 0;
    painter.addListener(() => heard++);
    clock.value = 0.5;
    expect(heard, 0);
    transform.value = Matrix4.translationValues(-10, 0, 0);
    expect(heard, 1);
  });

  test('a rebuild showing the same cells is not repainted', () {
    final clock = ValueNotifier(0.0);
    final transform = TransformationController();
    MapStandingPainter build({Size viewport = const Size(10, 10)}) =>
        painterOf([...row],
            clock: clock, transform: transform, viewport: viewport);
    expect(build().shouldRepaint(build()), isFalse);
    expect(
        build().shouldRepaint(build(viewport: const Size(20, 10))), isTrue);
    expect(build().shouldRepaint(painterOf(row, transform: transform)),
        isTrue);
  });
}

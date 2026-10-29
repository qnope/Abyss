import 'package:abyss/presentation/theme/abyss_colors.dart';
import 'package:abyss/presentation/widgets/ambience/ambient_motion.dart';
import 'package:abyss/presentation/widgets/map/map_cell_visual.dart';
import 'package:abyss/presentation/widgets/map/map_content_spot.dart';
import 'package:abyss/presentation/widgets/map/map_projection.dart';
import 'package:abyss/presentation/widgets/map/map_sprites.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

import 'map_standing_probe.dart';

const _faille = 'assets/icons/posts/faille_guarded.svg';

void main() {
  late MapSprites sprites;

  /// Loads the shared sprites, for [paintAlone].
  Future<void> load(WidgetTester tester) async =>
      sprites = (await tester.runAsync(MapSprites.load))!;

  /// Paints [visual] alone on a map of one cell.
  void Function(Canvas) paintAlone(MapCellVisual visual) =>
      paintOf(standingPainterOf([visual], columns: 1, sprites: sprites));

  final spot = MapContentSpot.of(standingCell(AmbientMotion.still), 0, 1);

  testWidgets('a standing content casts its soft shadow under it',
      (tester) async {
    await load(tester);
    expect(
      paintAlone(standingCell(AmbientMotion.still)),
      paints
        ..drawImageRect(image: sprites.shadow, destination: spot.shadow)
        ..drawImageRect(
            image: sprites.svg(playerBaseSvgPath), destination: spot.area),
    );
  });

  testWidgets('a collected content keeps its dimming, over its shadow',
      (tester) async {
    await load(tester);
    expect(
      paintAlone(standingCell(AmbientMotion.still, dimmed: true)),
      paints
        ..drawImageRect(image: sprites.shadow)
        ..drawImageRect(
          image: sprites.svg(playerBaseSvgPath),
          destination: spot.area,
          color: const Color.fromRGBO(0, 0, 0, 0.3),
        ),
    );
  });

  testWidgets('a pulsing glow is a pool of light on the floor, at its pulse',
      (tester) async {
    await load(tester);
    final post = standingCell(AmbientMotion.pulse, glow: MapGlow.post);
    final glow = AmbientMotion.pulse.at(1.3, phase: AmbientMotion.phaseOf(0));
    expect(
      paintAlone(post),
      paints
        ..drawImageRect(
          image: sprites.pool(MapGlow.post),
          destination: spot.glow,
          color: Color.fromRGBO(0, 0, 0, glow.glow),
        ),
    );
  });

  testWidgets('a faction ring lies on the floor around the base',
      (tester) async {
    await load(tester);
    final base = standingCell(AmbientMotion.breathe,
        factionColor: AbyssColors.coralPink);
    expect(
      paintAlone(base),
      paints
        ..something((method, args) =>
            method == #drawOval &&
            args[0] == spot.ring &&
            (args[1] as Paint).color.toARGB32() ==
                AbyssColors.coralPink.toARGB32())
        ..drawImageRect(image: sprites.svg(playerBaseSvgPath)),
    );
  });

  testWidgets('a hole lying flat only leaves its glow to the standing layer',
      (tester) async {
    await load(tester);
    final faille =
        standingCell(AmbientMotion.pulse, glow: MapGlow.post, sprite: _faille);
    final paint = paintAlone(faille);
    expect(paint,
        paints..drawImageRect(image: sprites.pool(MapGlow.post)));
    expect(paint, paintsExactlyCountTimes(#drawImageRect, 1));
  });

  testWidgets('a wreck seen through the fog stands with its halo',
      (tester) async {
    await load(tester);
    const beacon = MapCellVisual(
      terrainSprite: 'plain.svg',
      contentSprite: playerBaseSvgPath,
      glow: MapGlow.wreck,
      aboveFog: true,
      motion: AmbientMotion.sway,
    );
    final paint = paintAlone(beacon);
    expect(
      paint,
      paints
        ..drawImageRect(
            image: sprites.pool(MapGlow.wreck), destination: spot.glow)
        ..drawImageRect(image: sprites.shadow)
        ..drawImageRect(destination: MapProjection.standingOf((0, 0))),
    );
    expect(paint, paintsExactlyCountTimes(#drawImageRect, 3));
  });
}

import 'package:abyss/domain/map/map_generator.dart';
import 'package:abyss/presentation/widgets/map/effects/map_effect_painter.dart';
import 'package:abyss/presentation/widgets/map/effects/map_effects.dart';
import 'package:abyss/presentation/widgets/map/effects/story/map_fog_lift.dart';
import 'package:abyss/presentation/widgets/map/game_map_view.dart';
import 'package:abyss/presentation/widgets/map/map_painter.dart';
import 'package:abyss/presentation/widgets/map/map_standing_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_svg_helper.dart';

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  testWidgets('an effect lays its floor between the still map and the '
      'standing contents, which it fades, and plays the rest over them', (
    tester,
  ) async {
    final effects = MapEffects();
    addTearDown(effects.dispose);
    effects.play(
        const MapFogLift(cells: {(6, 12): 'tile.svg'}, focus: (6, 12)),
        awaitStage: true);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: GameMapView(
          gameMap: MapGenerator.generate(seed: 42).map,
          revealedCells: const {},
          baseX: 6,
          baseY: 13,
          humanPlayerId: 'human',
          effects: effects,
        ),
      ),
    ));
    final painters = [
      for (final element in find.byType(CustomPaint).evaluate())
        (element.widget as CustomPaint).painter,
    ];
    int indexOf<T>() => painters.indexWhere((p) => p is T);
    expect(indexOf<MapPainter>(), lessThan(indexOf<MapEffectFloorPainter>()));
    expect(indexOf<MapEffectFloorPainter>(),
        lessThan(indexOf<MapStandingPainter>()));
    expect(indexOf<MapStandingPainter>(), lessThan(indexOf<MapEffectPainter>()));
    final standing =
        painters.whereType<MapStandingPainter>().single;
    expect(standing.fade, same(effects.fade));
    expect(effects.fade.cells, {(6, 12)});
    effects.finish();
  });
}

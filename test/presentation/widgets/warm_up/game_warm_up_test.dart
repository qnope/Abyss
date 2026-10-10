import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/presentation/theme/abyss_colors.dart';
import 'package:abyss/presentation/widgets/building/building_card.dart';
import 'package:abyss/presentation/widgets/common/raster_svg.dart';
import 'package:abyss/presentation/widgets/common/svg_raster_cache.dart';
import 'package:abyss/presentation/widgets/map/map_cell_visual.dart';
import 'package:abyss/presentation/widgets/map/map_painter.dart';
import 'package:abyss/presentation/widgets/map/map_sprites.dart';
import 'package:abyss/presentation/widgets/unit/unit_card.dart';
import 'package:abyss/presentation/widgets/warm_up/game_warm_up.dart';
import 'package:abyss/presentation/widgets/warm_up/greyable_icon_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/localized_app.dart';

const _greyed = [
  'assets/icons/buildings/laboratory.svg',
  'assets/icons/units/scout.svg',
  'assets/icons/tech/military_1.svg',
  'assets/icons/tech/explorer_4b.svg',
  'assets/icons/resources/algae.svg',
  'assets/icons/terrain/volcanic_kernel.svg',
];

void main() {
  /// Shows the warm-up page [index] once the game art is loaded.
  Future<void> showPage(WidgetTester tester, int index) async {
    await tester.runAsync(preloadGameArt);
    await tester.pumpWidget(localizedApp(
      SingleChildScrollView(child: Builder(builder: gameWarmUpPages[index])),
    ));
  }

  test('every icon that can be greyed is listed once', () {
    final paths = greyableIconPaths();
    expect(paths, containsAll(_greyed));
    expect(paths.toSet().length, paths.length);
  });

  testWidgets('preloads the greyscale bitmap of every greyable icon', (
    tester,
  ) async {
    await tester.runAsync(preloadGameArt);
    for (final path in _greyed) {
      expect(SvgRasterCache.peekGrey(path), isNotNull, reason: path);
    }
  });

  testWidgets('icons page draws icons in colour and faded greyscale', (
    tester,
  ) async {
    await showPage(tester, 1);
    final icons = tester.widgetList<RasterSvg>(find.byType(RasterSvg));
    expect(icons.where((i) => !i.greyscale && i.opacity == 1), isNotEmpty);
    final greyed = icons.where((i) => i.greyscale);
    expect(greyed.map((i) => i.assetPath), containsAll(_greyed));
    expect(
      greyed.every((i) => i.opacity == AbyssColors.unavailableOpacity),
      isTrue,
    );
  });
  testWidgets('cards page shows building and unit cards in both states', (
    tester,
  ) async {
    await showPage(tester, 0);
    expect(tester.takeException(), isNull);
    final buildings =
        tester.widgetList<BuildingCard>(find.byType(BuildingCard));
    expect(buildings.map((c) => c.building.type),
        everyElement(BuildingType.headquarters));
    expect(buildings.map((c) => c.building.level), [0, 1]);
    final units = tester.widgetList<UnitCard>(find.byType(UnitCard));
    expect(units.map((c) => c.isUnlocked), [false, true]);
    expect(find.textContaining('0123456789'), findsNWidgets(3));
  });

  testWidgets('map page paints every sprite and every glow', (tester) async {
    await showPage(tester, 2);
    expect(tester.takeException(), isNull);
    final paint = tester.widget<CustomPaint>(find.byWidgetPredicate(
        (w) => w is CustomPaint && w.painter is MapPainter));
    final painter = paint.painter! as MapPainter;
    final visuals = painter.visuals;
    expect(painter.sprites, same(MapSprites.ready));
    expect(visuals.map((v) => v.contentSprite),
        containsAll(MapSprites.svgPaths));
    expect(visuals.map((v) => v.glow).toSet(), MapGlow.values.toSet());
    expect(visuals.any((v) => !v.revealed), isTrue);
    expect(visuals.any((v) => v.aboveFog), isTrue);
    expect(visuals.any((v) => v.dimmed && v.pending), isTrue);
    expect(paint.size.width, painter.columns * cellSize);
  });
}

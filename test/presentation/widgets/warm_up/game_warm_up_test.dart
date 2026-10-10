import 'package:abyss/presentation/theme/abyss_colors.dart';
import 'package:abyss/presentation/widgets/common/raster_svg.dart';
import 'package:abyss/presentation/widgets/common/svg_raster_cache.dart';
import 'package:abyss/presentation/widgets/warm_up/game_warm_up.dart';
import 'package:abyss/presentation/widgets/warm_up/greyable_icon_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _greyed = [
  'assets/icons/buildings/laboratory.svg',
  'assets/icons/units/scout.svg',
  'assets/icons/tech/military_1.svg',
  'assets/icons/tech/explorer_4b.svg',
  'assets/icons/resources/algae.svg',
  'assets/icons/terrain/volcanic_kernel.svg',
];

void main() {
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
    await tester.runAsync(preloadGameArt);
    await tester.pumpWidget(MaterialApp(
      home: SingleChildScrollView(child: Builder(builder: gameWarmUpPages[1])),
    ));
    final icons = tester.widgetList<RasterSvg>(find.byType(RasterSvg));
    expect(icons.where((i) => !i.greyscale && i.opacity == 1), isNotEmpty);
    final greyed = icons.where((i) => i.greyscale);
    expect(greyed.map((i) => i.assetPath), containsAll(_greyed));
    expect(
      greyed.every((i) => i.opacity == AbyssColors.unavailableOpacity),
      isTrue,
    );
  });
}

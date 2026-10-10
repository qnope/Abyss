import 'package:flutter/material.dart';

import '../../../domain/building/building.dart';
import '../../../domain/building/building_type.dart';
import '../../../domain/unit/unit_type.dart';
import '../../theme/abyss_colors.dart';
import '../building/building_card.dart';
import '../common/raster_svg.dart';
import '../common/svg_raster_cache.dart';
import '../map/map_cell_visual.dart';
import '../map/map_painter.dart';
import '../map/map_sprites.dart';
import '../unit/unit_card.dart';
import 'greyable_icon_paths.dart';

/// Rasterizes every icon and map sprite, plus the greyscale bitmap of
/// every icon that can be greyed: meant to run once at startup.
Future<void> preloadGameArt() async {
  await SvgRasterCache.preloadAll();
  await SvgRasterCache.preloadGrey(greyableIconPaths());
  await MapSprites.load();
}

/// Samples of what the game screens draw, for a [WarmUpLayer]: list
/// cards in both states, every icon in colour and greyscale, and a map
/// with every sprite.
final List<WidgetBuilder> gameWarmUpPages = [
  (_) => const _CardsPage(),
  (_) => const _IconsPage(),
  (_) => const _MapPage(),
];

const _glyphs = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ abcdefghijklmnopqrstuvwxyz '
    "0123456789 éèêëàâçîïôûùáíóúñüÉÁÍÓÚÑ¿¡'·:+-/.,()";

class _CardsPage extends StatelessWidget {
  const _CardsPage();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    void noop() {}
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final level in [0, 1])
          BuildingCard(
            building: Building(type: BuildingType.headquarters, level: level),
            onTap: noop,
          ),
        for (final unlocked in [false, true])
          UnitCard(
            unitType: UnitType.values.first,
            countsPerLevel: const {1: 1},
            isUnlocked: unlocked,
            onTap: noop,
          ),
        for (final style in [text.titleMedium, text.bodySmall, text.bodyMedium])
          Text(_glyphs, style: style),
      ],
    );
  }
}

class _IconsPage extends StatelessWidget {
  const _IconsPage();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        for (final path in SvgRasterCache.readyPaths.toList())
          RasterSvg(assetPath: path, size: 40),
        for (final path in greyableIconPaths())
          RasterSvg(
            assetPath: path,
            size: 40,
            greyscale: true,
            opacity: AbyssColors.unavailableOpacity,
          ),
      ],
    );
  }
}

class _MapPage extends StatelessWidget {
  const _MapPage();

  @override
  Widget build(BuildContext context) {
    final paths = MapSprites.svgPaths.toList();
    final visuals = [
      for (final path in paths)
        MapCellVisual(terrainSprite: paths.first, contentSprite: path,
            revealed: true),
      for (final glow in MapGlow.values)
        MapCellVisual(terrainSprite: paths.last, glow: glow, dimmed: true,
            contentSprite: paths.first, revealed: true, pending: true),
      MapCellVisual(terrainSprite: paths.first),
      MapCellVisual(terrainSprite: paths.first, contentSprite: paths.last,
          glow: MapGlow.wreck, aboveFog: true),
    ];
    const columns = 8;
    final rows = (visuals.length / columns).ceil();
    return CustomPaint(
      size: Size(columns * cellSize, rows * cellSize),
      painter: MapPainter(
        visuals: visuals,
        columns: columns,
        sprites: MapSprites.ready,
      ),
    );
  }
}

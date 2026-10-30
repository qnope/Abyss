import 'package:flutter/material.dart';

import '../../../domain/building/building.dart';
import '../../../domain/building/building_type.dart';
import '../../../domain/map/terrain_type.dart';
import '../../../domain/unit/unit_type.dart';
import '../../extensions/terrain_type_extensions.dart';
import '../../theme/abyss_colors.dart';
import '../army/army_sprites.dart';
import '../building/building_card.dart';
import '../common/raster_svg.dart';
import '../common/svg_raster_cache.dart';
import '../map/map_cell_visual.dart';
import '../map/map_painter.dart';
import '../map/map_projection.dart';
import '../map/map_sprites.dart';
import '../map/map_standing_painter.dart';
import '../unit/unit_card.dart';
import 'greyable_icon_paths.dart';

/// Rasterizes every icon and map sprite, the greyscale bitmap of every
/// icon that can be greyed and the army's standing units: meant to run
/// once at startup.
Future<void> preloadGameArt() async {
  await SvgRasterCache.preloadAll();
  await SvgRasterCache.preloadGrey(greyableIconPaths());
  await MapSprites.load();
  await ArmySprites.load();
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
    final tiles = TerrainType.plain.tileSvgPaths;
    const columns = 8;
    final visuals = [
      // Bare rows, seen then hidden, for decor over and under the fog.
      for (var i = 0; i < 6 * columns; i++)
        MapCellVisual(terrainSprite: tiles[i % tiles.length],
            revealed: i < 3 * columns),
      for (final (i, path) in paths.indexed)
        MapCellVisual(terrainSprite: tiles[i % tiles.length],
            contentSprite: path, revealed: true),
      for (final glow in MapGlow.values)
        MapCellVisual(terrainSprite: paths.last, glow: glow, dimmed: true,
            contentSprite: paths.first, revealed: true, pending: true),
      MapCellVisual(terrainSprite: paths.first),
      MapCellVisual(terrainSprite: paths.first, contentSprite: paths.last,
          glow: MapGlow.wreck, aboveFog: true),
    ];
    final rows = (visuals.length / columns).ceil();
    final size = MapProjection.sizeOf(columns, rows);
    return Transform.translate(
      offset: MapProjection.originOf(rows),
      child: Stack(children: [
        CustomPaint(
          size: size,
          painter: MapPainter(visuals: visuals, columns: columns,
              sprites: MapSprites.ready, decorSalt: 1),
        ),
        CustomPaint(
          size: size,
          painter: MapStandingPainter(
            visuals: visuals,
            columns: columns,
            sprites: MapSprites.ready,
            clock: const AlwaysStoppedAnimation(0),
            transform: ValueNotifier(Matrix4.identity()),
            viewport: size,
          ),
        ),
      ]),
    );
  }
}

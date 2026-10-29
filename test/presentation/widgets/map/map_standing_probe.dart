import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/presentation/extensions/terrain_type_extensions.dart';
import 'package:abyss/presentation/widgets/ambience/ambient_motion.dart';
import 'package:abyss/presentation/widgets/ambience/creature_sheet.dart';
import 'package:abyss/presentation/widgets/map/map_cell_visual.dart';
import 'package:abyss/presentation/widgets/map/map_content_fade.dart';
import 'package:abyss/presentation/widgets/map/map_creature_sheets.dart';
import 'package:abyss/presentation/widgets/map/map_projection.dart';
import 'package:abyss/presentation/widgets/map/map_sprites.dart';
import 'package:abyss/presentation/widgets/map/map_standing_painter.dart';
import 'package:flutter/widgets.dart';

/// A seen cell showing [sprite] (the player's base by default) in [motion].
MapCellVisual standingCell(
  AmbientMotion motion, {
  MapGlow glow = MapGlow.none,
  String sprite = playerBaseSvgPath,
  bool dimmed = false,
  Color? factionColor,
}) =>
    MapCellVisual(
      terrainSprite: TerrainType.plain.tileSvgPaths.first,
      contentSprite: sprite,
      glow: glow,
      dimmed: dimmed,
      factionColor: factionColor,
      revealed: true,
      motion: motion,
    );

/// The standing painter of [visuals], laid [columns] cells wide, seeing
/// the whole map unless told otherwise.
MapStandingPainter standingPainterOf(
  List<MapCellVisual> visuals, {
  required int columns,
  MapSprites? sprites,
  ValueNotifier<double>? clock,
  ValueNotifier<Matrix4>? transform,
  Size? viewport,
  MapContentFade? fade,
  CreatureSheet? Function(String sprite) creatureSheetOf =
      MapCreatureSheets.peek,
}) =>
    MapStandingPainter(
      visuals: visuals,
      columns: columns,
      sprites: sprites,
      clock: clock ?? ValueNotifier(1.3),
      transform: transform ?? TransformationController(),
      viewport: viewport ??
          MapProjection.sizeOf(columns, visuals.length ~/ columns),
      fade: fade,
      creatureSheetOf: creatureSheetOf,
    );

/// Paints [painter] over the box of its map.
void Function(Canvas) paintOf(MapStandingPainter painter) => (canvas) =>
    painter.paint(
        canvas,
        MapProjection.sizeOf(
            painter.columns, painter.visuals.length ~/ painter.columns));

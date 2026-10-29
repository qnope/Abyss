import 'package:flutter/material.dart';
import '../../../domain/map/game_map.dart';
import '../../../domain/map/grid_position.dart';
import '../../../domain/map/post_holder.dart';
import 'effects/map_effects.dart';
import 'map_cell_visual.dart';
import 'map_centring.dart';
import 'map_layers.dart';
import 'map_projection.dart';
import 'map_sprites_loading.dart';
import 'map_viewport.dart';
import 'map_visuals_builder.dart';
import 'scout_origin.dart';

class GameMapView extends StatefulWidget {
  final GameMap gameMap;
  final Set<GridPosition> revealedCells;
  final int? baseX;
  final int? baseY;
  final String humanPlayerId;
  final void Function(int x, int y)? onCellTap;
  final Set<(int, int)> pendingTargets;

  /// Colour of the faction base standing on each cell, level 1 only.
  final Map<GridPosition, Color> factionBases;

  /// Seal colour of each player who can hold the volcano, by player id.
  final Map<String, Color> ownerColors;

  /// Who holds the post above each passage of [gameMap], by position.
  final Map<GridPosition, PostHolder> passageHolders;

  /// Level of [gameMap], where the guide's halo may surround a cell.
  final int level;

  /// Effects played over the map; a tap on the map skips the one playing,
  /// and the map centres on what each one is about.
  final MapEffects? effects;

  const GameMapView({
    super.key,
    required this.gameMap,
    required this.revealedCells,
    this.baseX,
    this.baseY,
    required this.humanPlayerId,
    this.onCellTap,
    this.pendingTargets = const {},
    this.factionBases = const {},
    this.ownerColors = const {},
    this.passageHolders = const {},
    this.level = 1,
    this.effects,
  });

  @override
  State<GameMapView> createState() => _GameMapViewState();
}

class _GameMapViewState extends State<GameMapView>
    with MapCentring, MapSpritesLoading {
  /// Tiles seen across the screen when zoomed in the most.
  static const _maxVisibleTiles = 1.5;

  @override
  (int, int) get home => (widget.baseX ?? widget.gameMap.width ~/ 2,
      widget.baseY ?? widget.gameMap.height ~/ 2);

  @override
  int get rows => widget.gameMap.height;

  @override
  MapEffects? get effects => widget.effects;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    centre();
  }

  @override
  void didUpdateWidget(GameMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    centre();
  }

  @override
  Widget build(BuildContext context) {
    final map = widget.gameMap;
    final screenWidth = MediaQuery.of(context).size.width;
    return MapViewport(
      controller: controller,
      minScale: screenWidth / MapProjection.sizeOf(map.width, rows).width,
      maxScale: screenWidth / (_maxVisibleTiles * MapProjection.tileWidth),
      onTapUp: widget.onCellTap == null ? null : _handleTap,
      builder: (context, clock, viewport) => MapLayers(
        visuals: _visuals(),
        columns: map.width,
        sprites: sprites,
        clock: clock,
        transform: controller,
        viewport: viewport,
        level: widget.level,
        pendingTargets: widget.pendingTargets,
        scoutOriginOf: _scoutOrigin,
        effects: widget.effects,
      ),
    );
  }

  List<MapCellVisual> _visuals() => buildMapVisuals(
        gameMap: widget.gameMap,
        revealedCells: widget.revealedCells,
        humanPlayerId: widget.humanPlayerId,
        baseX: widget.baseX,
        baseY: widget.baseY,
        pendingTargets: widget.pendingTargets,
        factionBases: widget.factionBases,
        ownerColors: widget.ownerColors,
        passageHolders: widget.passageHolders,
      );

  (int, int) _scoutOrigin((int, int) target) => scoutOrigin(target,
      base: widget.baseX == null ? null : (widget.baseX!, widget.baseY!),
      passageHolders: widget.passageHolders,
      revealed: widget.revealedCells);

  void _handleTap(TapUpDetails details) {
    final effects = widget.effects;
    if (effects != null && effects.isPlaying) return effects.skip();
    final cell = MapProjection.cellAt(
        details.localPosition - MapProjection.originOf(rows),
        columns: widget.gameMap.width,
        rows: rows);
    if (cell != null) widget.onCellTap!(cell.$1, cell.$2);
  }
}

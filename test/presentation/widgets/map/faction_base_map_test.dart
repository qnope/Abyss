import 'package:abyss/domain/faction/faction_personality.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/game_factory.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/presentation/theme/faction_colors.dart';
import 'package:abyss/presentation/widgets/map/game_map_view.dart';
import 'package:abyss/presentation/widgets/map/map_cell_visual.dart';
import 'package:abyss/presentation/widgets/map/map_visuals_builder.dart';
import 'package:abyss/presentation/widgets/map/map_projection.dart';
import 'package:abyss/presentation/widgets/map/map_sprites.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/map_tab_harness.dart';
import 'map_standing_probe.dart';

void main() {
  final colour = FactionColors.of(FactionPersonality.anglerCult);
  final base = GridPosition(x: 2, y: 3);

  List<MapCellVisual> visuals({
    required Set<GridPosition> revealed,
    Set<GridPosition> bases = const {},
  }) =>
      buildMapVisuals(
        gameMap: plainMap(),
        revealedCells: revealed,
        humanPlayerId: 'me',
        factionBases: {for (final p in bases) p: colour},
      );

  int indexOf(GridPosition p) => p.y * harnessMapSize + p.x;

  test('a revealed faction base shows the base in its colour', () {
    final v = visuals(revealed: {base}, bases: {base})[indexOf(base)];
    expect(v.factionColor, colour);
    expect(v.contentSprite, playerBaseSvgPath);
  });

  test('a faction base in the fog is not drawn', () {
    final v = visuals(revealed: {}, bases: {base})[indexOf(base)];
    expect(v.factionColor, isNull);
    expect(v.contentSprite, isNull);
  });

  test('every faction has its own colour', () {
    final colours = FactionPersonality.values.map(FactionColors.of).toSet();
    expect(colours, hasLength(FactionPersonality.values.length));
  });

  test('without factions the map is the same as before', () {
    final revealed = allPositions().toSet();
    expect(
      visuals(revealed: revealed),
      buildMapVisuals(
        gameMap: plainMap(),
        revealedCells: revealed,
        humanPlayerId: 'me',
      ),
    );
    expect(visuals(revealed: revealed).any((v) => v.factionColor != null),
        isFalse);
  });

  testWidgets('the standing layer rings the base on the floor in its colour',
      (tester) async {
    final sprites = await tester.runAsync(MapSprites.load);
    final painter = standingPainterOf([
      MapCellVisual(terrainSprite: 'x', revealed: true, factionColor: colour),
    ], columns: 1, sprites: sprites);
    final centre = MapProjection.centreOf((0, 0));
    expect(
      paintOf(painter),
      paints
        ..something((method, args) {
          if (method != #drawOval) return false;
          final ring = args[0] as Rect;
          return ring.center == centre &&
              ring.width == 2 * ring.height &&
              (args[1] as Paint).color.toARGB32() == colour.toARGB32();
        }),
    );
  });

  Game withFactions(int count) =>
      GameFactory.newGame(playerName: 'Nemo', mapSeed: 7, factionCount: count);

  testWidgets('the map tab hands each faction base to the map', (tester) async {
    final game = withFactions(3);
    await tester.pumpWidget(mapTabHost(game));
    final bases = tester.widget<GameMapView>(find.byType(GameMapView))
        .factionBases;
    expect(bases, hasLength(3));
    for (final faction in game.factions) {
      final player = game.players[faction.id]!;
      expect(
        bases[GridPosition(x: player.baseX, y: player.baseY)],
        FactionColors.of(faction.personality),
      );
    }
  });

  testWidgets('a solo game hands no faction base to the map', (tester) async {
    await tester.pumpWidget(mapTabHost(withFactions(0)));
    expect(
      tester.widget<GameMapView>(find.byType(GameMapView)).factionBases,
      isEmpty,
    );
  });
}

import 'package:abyss/domain/faction/faction.dart';
import 'package:abyss/domain/faction/faction_personality.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/map_cell.dart';
import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/presentation/widgets/common/raster_svg.dart';
import 'package:abyss/presentation/widgets/faction/faction_emblem.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/map_tab_harness.dart';
import '../../../helpers/test_svg_helper.dart';

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  const nomads = Faction(FactionPersonality.currentNomads);

  Future<void> tapLairTakenBy(
    WidgetTester tester,
    String Function(String) id,
  ) async {
    final game = harnessGame(plainMap());
    final rival = Player(id: nomads.id, name: nomads.name, baseX: 9, baseY: 9);
    game.players[rival.id] = rival;
    game.savedFactions = [nomads.personality];
    game.levels[1]!.setCell(
      2,
      2,
      MapCell(
        terrain: TerrainType.plain,
        content: CellContentType.monsterLair,
        collectedBy: id(game.humanPlayerId),
      ),
    );
    await tester.pumpWidget(mapTabHost(game));
    await tester.pumpAndSettle();
    await tapMapCell(tester, 2, 2);
  }

  testWidgets('a lair a faction emptied names that faction', (tester) async {
    await tapLairTakenBy(tester, (_) => nomads.id);
    expect(find.text('Pris par Les Nomades du Courant'), findsOneWidget);
    expect(find.text("Il n'y a plus rien à prendre ici"), findsOneWidget);
    expect(find.text('Déjà visité'), findsNothing);
    final svg = tester.widget<RasterSvg>(find.byType(RasterSvg).last);
    expect(svg.assetPath, FactionEmblem.assetOf(nomads.personality));
  });

  testWidgets('a lair the human emptied is already visited', (tester) async {
    await tapLairTakenBy(tester, (human) => human);
    expect(find.text('Déjà visité'), findsOneWidget);
    expect(find.textContaining('Pris par'), findsNothing);
  });
}

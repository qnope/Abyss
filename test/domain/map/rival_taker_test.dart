import 'package:abyss/domain/faction/faction.dart';
import 'package:abyss/domain/faction/faction_personality.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/map_cell.dart';
import 'package:abyss/domain/map/rival_taker.dart';
import 'package:abyss/domain/map/terrain_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const nomads = Faction(FactionPersonality.currentNomads);
  final human = Player(name: 'Nemo', baseX: 1, baseY: 1);
  final rival = Player(id: nomads.id, name: nomads.name, baseX: 8, baseY: 8);
  final game = Game(
    humanPlayerId: human.id,
    players: {human.id: human, rival.id: rival},
  )..savedFactions = [FactionPersonality.currentNomads];

  MapCell lairTakenBy(String? id) => MapCell(
    terrain: TerrainType.plain,
    content: CellContentType.monsterLair,
    collectedBy: id,
  );

  test('a cell taken by a faction names that faction', () {
    final taker = RivalTaker.of(game, lairTakenBy(nomads.id));
    expect(taker?.personality, FactionPersonality.currentNomads);
  });

  test('a cell the human took has no rival taker', () {
    expect(RivalTaker.of(game, lairTakenBy(human.id)), isNull);
  });

  test('a cell nobody took has no rival taker', () {
    expect(RivalTaker.of(game, lairTakenBy(null)), isNull);
  });

  test('a cell taken by an unknown player has no rival taker', () {
    expect(RivalTaker.of(game, lairTakenBy('someone')), isNull);
  });
}

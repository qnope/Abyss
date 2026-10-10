import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/faction/faction_standing.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/game_factory.dart';
import 'package:abyss/domain/map/transition_base.dart';
import 'package:flutter_test/flutter_test.dart';

Game _game(int factions) => GameFactory.newGame(
      playerName: 'Nemo',
      mapSeed: 7,
      factionCount: factions,
    );

TransitionBase _baseOnLevel(Game game, int level) => game.levels[level]!.cells
    .map((c) => c.transitionBase)
    .whereType<TransitionBase>()
    .first;

void main() {
  test('a solo game has no ranking', () {
    expect(FactionStanding.ranking(_game(0)), isEmpty);
  });

  test('the ranking lists the human and every faction', () {
    final game = _game(3);
    final ranking = FactionStanding.ranking(game);
    expect(ranking, hasLength(4));
    expect(ranking.where((s) => s.isHuman).single.name, 'Nemo');
    expect(
      ranking.map((s) => s.personality).whereType<Object>(),
      game.factions.map((f) => f.personality),
    );
  });

  test('a fresh player is at level one, without kernel', () {
    final standing = FactionStanding.of(_game(2), _game(2).humanPlayer);
    expect(standing.deepestLevel, 1);
    expect(standing.holdsKernel, isFalse);
    expect(standing.headquartersLevel, 0);
    expect(standing.hasFallen, isFalse);
  });

  test('depth follows the captured posts and the kernel', () {
    final game = _game(2);
    final faction = game.players[game.factions.first.id]!;
    _baseOnLevel(game, 1).capturedBy = faction.id;
    expect(FactionStanding.of(game, faction).deepestLevel, 2);
    final cells = game.levels[3]!.cells;
    final i = cells.indexWhere((c) => c.content.name == 'volcanicKernel');
    cells[i] = cells[i].copyWith(collectedBy: faction.id);
    final standing = FactionStanding.of(game, faction);
    expect(standing.deepestLevel, 3);
    expect(standing.holdsKernel, isTrue);
  });

  test('the most advanced come first and the fallen last', () {
    final game = _game(3);
    final first = game.players[game.factions[1].id]!;
    first.buildings[BuildingType.headquarters]!.level = 4;
    game.players[game.factions[0].id]!.savedFallen = true;
    final ranking = FactionStanding.ranking(game);
    expect(ranking.first.personality, game.factions[1].personality);
    expect(ranking.last.personality, game.factions[0].personality);
    expect(ranking.last.hasFallen, isTrue);
  });
}

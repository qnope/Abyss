import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/difficulty.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/game_status.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/game/save_outcome.dart';
import 'package:abyss/domain/game/save_summary.dart';
import 'package:abyss/domain/map/game_map.dart';
import 'package:abyss/domain/map/map_cell.dart';
import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:flutter_test/flutter_test.dart';

GameMap _map() => GameMap(
      width: 1,
      height: 1,
      cells: [MapCell(terrain: TerrainType.plain)],
      seed: 1,
    );

Game _game({
  GameStatus status = GameStatus.playing,
  Map<int, GameMap> levels = const {},
}) {
  final Player player = Player(id: 'nemo', name: 'Nemo');
  return Game(
    humanPlayerId: player.id,
    players: {player.id: player},
    turn: 12,
    createdAt: DateTime(2026, 3, 1),
    levels: levels,
    status: status,
    difficulty: Difficulty.hard,
  );
}

void main() {
  test('sums up who plays, which turn and at which difficulty', () {
    final SaveSummary summary = SaveSummary.of(_game());
    expect(summary.playerName, 'Nemo');
    expect(summary.turn, 12);
    expect(summary.difficulty, Difficulty.hard);
  });

  test('a lost game shows the turn its base fell on', () {
    expect(SaveSummary.of(_game(status: GameStatus.defeat)).turn, 11);
  });

  test('a won game shows its current turn', () {
    expect(SaveSummary.of(_game(status: GameStatus.victory)).turn, 12);
  });

  test('sorts each status into its outcome', () {
    SaveOutcome outcomeOf(GameStatus status) =>
        SaveSummary.of(_game(status: status)).outcome;
    expect(outcomeOf(GameStatus.playing), SaveOutcome.inProgress);
    expect(outcomeOf(GameStatus.victory), SaveOutcome.victory);
    expect(outcomeOf(GameStatus.freePlay), SaveOutcome.victory);
    expect(outcomeOf(GameStatus.defeat), SaveOutcome.defeat);
  });

  test('only a game still being played is in progress', () {
    expect(SaveOutcome.inProgress.isFinished, isFalse);
    expect(SaveOutcome.victory.isFinished, isTrue);
    expect(SaveOutcome.defeat.isFinished, isTrue);
  });

  test('the deepest level is the deepest map generated', () {
    final Game game = _game(levels: {1: _map(), 3: _map(), 2: _map()});
    expect(SaveSummary.of(game).deepestLevel, 3);
  });

  test('a game without any map is still at the surface', () {
    expect(SaveSummary.of(_game()).deepestLevel, 1);
  });

  test('gives the headquarters level', () {
    final Game game = _game();
    game.humanPlayer.buildings[BuildingType.headquarters]!.level = 4;
    expect(SaveSummary.of(game).headquartersLevel, 4);
  });

  test('a player without headquarters is at level 0', () {
    final Game game = _game();
    game.humanPlayer.buildings.remove(BuildingType.headquarters);
    expect(SaveSummary.of(game).headquartersLevel, 0);
  });

  test('gives every resource amount in the resource order', () {
    final Game game = _game();
    game.humanPlayer.resources[ResourceType.pearl]!.amount = 42;
    game.humanPlayer.resources.remove(ResourceType.energy);

    final Map<ResourceType, int> resources = SaveSummary.of(game).resources;

    expect(resources.keys, ResourceType.values);
    expect(resources[ResourceType.pearl], 42);
    expect(resources[ResourceType.energy], 0);
    expect(
      resources[ResourceType.algae],
      game.humanPlayer.resources[ResourceType.algae]!.amount,
    );
  });

  test('gives when the game was last played', () {
    final Game game = _game()..savedLastPlayedAt = DateTime(2026, 4, 2, 9);
    expect(SaveSummary.of(game).lastPlayedAt, DateTime(2026, 4, 2, 9));
  });
}

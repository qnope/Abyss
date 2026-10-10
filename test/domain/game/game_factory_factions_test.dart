import 'package:abyss/domain/action/action_executor.dart';
import 'package:abyss/domain/action/end_turn_action.dart';
import 'package:abyss/domain/action/explore_action.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/faction/faction_catalogue.dart';
import 'package:abyss/domain/faction/faction_personality.dart';
import 'package:abyss/domain/game/difficulty.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/game_factory.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/map/map_generator.dart';
import 'package:abyss/domain/unit/unit.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/map_fingerprint.dart';

Game withFactions(int count, {int seed = 11}) => GameFactory.newGame(
  playerName: 'Nemo',
  mapSeed: seed,
  factionCount: count,
);

void main() {
  test('a game without faction is the single-player game, byte for byte', () {
    final solo = GameFactory.newSinglePlayer(playerName: 'Nemo', mapSeed: 5);
    final none = withFactions(0, seed: 5);

    expect(none.players, hasLength(1));
    expect(none.factions, isEmpty);
    expect(none.levels.keys, solo.levels.keys);
    expect(mapFingerprint(none.levels[1]!), mapFingerprint(solo.levels[1]!));
    expect(none.humanPlayer.baseX, solo.humanPlayer.baseX);
    expect(none.humanPlayer.baseY, solo.humanPlayer.baseY);
    expect(none.replay!.mapSeed, 5);
  });

  test('each faction is a real player on a base of its own', () {
    final game = withFactions(3);
    final bases = MapGenerator.generate(seed: 11, playerCount: 4).bases;

    expect(game.players, hasLength(4));
    expect(game.factions, hasLength(3));
    expect(game.humanPlayer.baseX, bases[0].x);
    for (var i = 0; i < 3; i++) {
      final faction = game.factions[i];
      final player = game.players[faction.id]!;
      expect(player.name, faction.name);
      expect([player.baseX, player.baseY], [bases[i + 1].x, bases[i + 1].y]);
      expect(
        player.buildings[BuildingType.headquarters]!.level,
        game.humanPlayer.buildings[BuildingType.headquarters]!.level,
      );
      expect(
        player.revealedCellsOnLevel(1),
        contains(GridPosition(x: player.baseX, y: player.baseY)),
      );
    }
  });

  test('the levels 2 and 3 exist from the start, on a bigger map', () {
    final game = withFactions(2);
    expect(game.levels.keys, [1, 2, 3]);
    expect(game.levels[1]!.width, 20);
    expect(withFactions(5).levels[1]!.width, 26);
    expect(withFactions(10).levels[1]!.width, 32);
  });

  test('the factions are drawn from the catalogue with the map seed', () {
    final game = withFactions(10);

    expect(game.factions.map((f) => f.personality).toSet(), hasLength(10));
    expect(
      withFactions(4).factions.map((f) => f.personality).toList(),
      FactionCatalogue.draw(4, seed: 11),
    );
  });

  test('explicit personalities are honoured', () {
    final game = GameFactory.newGame(
      playerName: 'Nemo',
      mapSeed: 3,
      personalities: [
        FactionPersonality.krakenFaithful,
        FactionPersonality.pearlOrder,
      ],
    );

    expect(game.factions.map((f) => f.personality), [
      FactionPersonality.krakenFaithful,
      FactionPersonality.pearlOrder,
    ]);
  });

  test('the difficulty and the tutorial choice reach a faction game', () {
    final game = GameFactory.newGame(
      playerName: 'Nemo',
      mapSeed: 3,
      difficulty: Difficulty.hard,
      tutorial: true,
      factionCount: 2,
    );

    expect(game.difficulty, Difficulty.hard);
    expect(game.humanPlayer.savedObjectiveState!.tutorialEnabled, isTrue);
    for (final faction in game.factions) {
      expect(
        game.players[faction.id]!.savedObjectiveState!.tutorialEnabled,
        isFalse,
      );
    }
  });

  test('1 to 10 factions only', () {
    expect(() => withFactions(11), throwsArgumentError);
    expect(() => withFactions(-1), throwsArgumentError);
  });

  test('the human exploring does not reveal anything to a faction', () {
    final game = withFactions(3);
    final faction = game.players[game.factions.first.id]!;
    final seen = faction.revealedCellsOnLevel(1).length;
    final human = game.humanPlayer;
    human.unitsPerLevel[1]![UnitType.scout] = Unit(
      type: UnitType.scout,
      count: 3,
    );
    final target = GridPosition(
      x: (human.baseX + 3) % 20,
      y: (human.baseY + 3) % 20,
    );

    final result = ActionExecutor().execute(
      ExploreAction(targetX: target.x, targetY: target.y, level: 1),
      game,
      human,
    );
    ActionExecutor().execute(
      EndTurnAction(playFactions: false),
      game,
      human,
    );

    expect(result.isSuccess, isTrue);
    expect(human.revealedCellsOnLevel(1), contains(target));
    expect(faction.revealedCellsOnLevel(1), hasLength(seen));
    expect(identical(faction.revealedCellsPerLevel, human.revealedCellsPerLevel),
        isFalse);
  });
}

import 'dart:io';

import 'package:abyss/data/game_repository.dart';
import 'package:abyss/domain/faction/faction_personality.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/game_factory.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

import 'game_repository_fight_persistence_helper.dart';

const _boxName = 'games';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('abyss_factions_');
    Hive.init(tempDir.path);
    registerFightPersistenceAdapters();
    await Hive.openBox<Game>(_boxName);
  });

  tearDown(() async {
    await Hive.deleteBoxFromDisk(_boxName);
    await Hive.close();
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  Future<Game> saveAndReload(Game game) async {
    await GameRepository().save(game);
    await Hive.close();
    Hive.init(tempDir.path);
    await Hive.openBox<Game>(_boxName);
    return GameRepository().loadAll().single;
  }

  test('the factions, their players and their fall survive a save', () async {
    final game = GameFactory.newGame(
      playerName: 'Nemo',
      mapSeed: 8,
      factionCount: 3,
    );
    game.players[game.factions.first.id]!.savedFallen = true;

    final loaded = await saveAndReload(game);

    expect(loaded.factions.map((f) => f.id), game.factions.map((f) => f.id));
    expect(
      loaded.factions.map((f) => f.personality),
      game.factions.map((f) => f.personality),
    );
    expect(loaded.players.keys, game.players.keys);
    expect(loaded.players[loaded.factions.first.id]!.hasFallen, isTrue);
    expect(loaded.players[loaded.factions.last.id]!.hasFallen, isFalse);
    expect(loaded.levels.keys, [1, 2, 3]);
    expect(
      loaded.players[loaded.factions.last.id]!.baseX,
      game.players[game.factions.last.id]!.baseX,
    );
  });

  test('a game saved before the factions has none and nobody fallen', () async {
    final game = GameFactory.newSinglePlayer(playerName: 'Nemo', mapSeed: 8);
    expect(game.savedFactions, isNull);

    final loaded = await saveAndReload(game);

    expect(loaded.savedFactions, isNull);
    expect(loaded.factions, isEmpty);
    expect(loaded.humanPlayer.hasFallen, isFalse);
    expect(loaded.humanPlayer.savedFallen, isNull);
    expect(FactionPersonality.values, hasLength(10));
  });
}

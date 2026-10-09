import 'dart:io';

import 'package:abyss/data/game_repository.dart';
import 'package:abyss/domain/game/difficulty.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

import 'game_repository_fight_persistence_helper.dart';

const _boxName = 'games';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('abyss_difficulty_');
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

  test('the difficulty picked at the start is kept in the save', () async {
    final Game game =
        buildFightPersistenceGame()..savedDifficulty = Difficulty.hard;
    final Game loaded = await saveAndReload(game);
    expect(loaded.difficulty, Difficulty.hard);
  });

  test('a save made before the difficulty existed plays in normal', () async {
    final Game game = buildFightPersistenceGame()..savedDifficulty = null;
    final Game loaded = await saveAndReload(game);
    expect(loaded.savedDifficulty, isNull);
    expect(loaded.difficulty, Difficulty.normal);
  });
}

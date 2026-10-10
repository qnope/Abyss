import 'dart:io';

import 'package:abyss/data/game_repository.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

import 'game_repository_fight_persistence_helper.dart';

const _boxName = 'games';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late DateTime clock;
  late GameRepository repository;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('abyss_last_played_');
    Hive.init(tempDir.path);
    registerFightPersistenceAdapters();
    await Hive.openBox<Game>(_boxName);
    clock = DateTime(2026, 6, 1, 10);
    repository = GameRepository(now: () => clock);
  });

  tearDown(() async {
    await Hive.deleteBoxFromDisk(_boxName);
    await Hive.close();
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  Future<Game> reload() async {
    await Hive.close();
    Hive.init(tempDir.path);
    await Hive.openBox<Game>(_boxName);
    return GameRepository().loadAll().single;
  }

  test('saving a new game stamps when it was last played', () async {
    final Game game = buildFightPersistenceGame();
    await repository.save(game);
    expect(game.lastPlayedAt, DateTime(2026, 6, 1, 10));
  });

  test('saving again moves the stamp to the new time', () async {
    final Game game = buildFightPersistenceGame();
    await repository.save(game);
    clock = DateTime(2026, 6, 2, 18, 45);
    await repository.save(game);
    expect(game.lastPlayedAt, DateTime(2026, 6, 2, 18, 45));
  });

  test('the stamp is kept in the save', () async {
    await repository.save(buildFightPersistenceGame());
    final Game loaded = await reload();
    expect(
      loaded.lastPlayedAt.millisecondsSinceEpoch,
      DateTime(2026, 6, 1, 10).millisecondsSinceEpoch,
    );
  });

  test('a save made before the stamp existed falls back to its creation',
      () async {
    final Game game = buildFightPersistenceGame();
    await Hive.box<Game>(_boxName).add(game);
    final Game loaded = await reload();
    expect(loaded.savedLastPlayedAt, isNull);
    expect(
      loaded.lastPlayedAt.millisecondsSinceEpoch,
      game.createdAt.millisecondsSinceEpoch,
    );
  });

  test('the default repository stamps with the current time', () async {
    final DateTime before = DateTime.now();
    final Game game = buildFightPersistenceGame();
    await GameRepository().save(game);
    expect(game.lastPlayedAt.isBefore(before), isFalse);
    expect(game.lastPlayedAt.isAfter(DateTime.now()), isFalse);
  });

  test('deleting a stored game removes only that game', () async {
    final Game first = buildFightPersistenceGame();
    final Game second = buildFightPersistenceGame();
    await repository.save(first);
    await repository.save(second);

    await repository.deleteGame(first);

    expect(repository.loadAll(), [same(second)]);
  });

  test('deleting a game that was never stored does nothing', () async {
    final Game stored = buildFightPersistenceGame();
    await repository.save(stored);

    await repository.deleteGame(buildFightPersistenceGame());

    expect(repository.loadAll(), [same(stored)]);
  });
}

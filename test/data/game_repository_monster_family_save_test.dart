import 'dart:io';

import 'package:abyss/data/game_repository.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/game_factory.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_family.dart';
import 'package:abyss/domain/map/monster_lair.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

import '../helpers/path_provider_mock.dart';

const _boxName = 'games';

Set<MonsterFamily?> _lairFamilies(Game game) => {
  for (final cell in game.currentMap.cells)
    if (cell.lair != null) cell.lair!.family,
};

/// Saves games through the real [GameRepository.initialize], so every
/// type a game holds must have its adapter registered there.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('abyss_family_save_');
    mockDocumentsDirectory(tempDir.path);
    await GameRepository.initialize();
  });

  tearDown(() async => Hive.box<Game>(_boxName).clear());

  tearDownAll(() async {
    await Hive.close();
    clearDocumentsDirectoryMock();
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  Future<Game> saveAndReload(Game game) async {
    await GameRepository().save(game);
    await Hive.box<Game>(_boxName).close();
    await Hive.openBox<Game>(_boxName);
    return GameRepository().loadAll().single;
  }

  test('a new game keeps the families of its lairs', () async {
    final Game game = GameFactory.newSinglePlayer(
      playerName: 'Nemo',
      mapSeed: 7,
    );
    final Set<MonsterFamily?> families = _lairFamilies(game);
    expect(families.whereType<MonsterFamily>(), isNotEmpty);

    final Game loaded = await saveAndReload(game);

    expect(_lairFamilies(loaded), families);
  });

  test('an announced raid keeps the two families of its wave', () async {
    final Game game = GameFactory.newSinglePlayer(
      playerName: 'Nemo',
      mapSeed: 7,
    );
    const MonsterLair wave = MonsterLair(
      difficulty: MonsterDifficulty.medium,
      unitCount: 4,
      family: MonsterFamily.swarm,
      secondFamily: MonsterFamily.hunter,
      secondCount: 2,
    );
    game.humanPlayer.raidState.announce(wave, 5);

    final Game loaded = await saveAndReload(game);

    final MonsterLair incoming = loaded.humanPlayer.raidState.incoming!;
    expect(incoming.family, MonsterFamily.swarm);
    expect(incoming.secondFamily, MonsterFamily.hunter);
    expect(incoming.secondCount, 2);
  });
}

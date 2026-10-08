import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:abyss/data/game_repository.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import '../helpers/path_provider_mock.dart';

Game _game(String name) => Game.singlePlayer(Player.withBase(
      name: name,
      baseX: 2,
      baseY: 3,
      mapWidth: 10,
      mapHeight: 10,
    ));

/// Exercises the real [GameRepository.initialize]. Hive adapters can only
/// be registered once per isolate, so it runs a single time for the file.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('abyss_repo_init_');
    mockDocumentsDirectory(tempDir.path);
    await GameRepository.initialize();
  });

  tearDown(() async => Hive.box<Game>('games').clear());

  tearDownAll(() async {
    await Hive.close();
    clearDocumentsDirectoryMock();
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  test('opens an empty games box in the documents directory', () {
    expect(Hive.isBoxOpen('games'), isTrue);
    expect(GameRepository().loadAll(), isEmpty);
    expect(File('${tempDir.path}/games.hive').existsSync(), isTrue);
  });

  test('save adds new games and loadAll returns them in order', () async {
    final repository = GameRepository();
    await repository.save(_game('Nemo'));
    await repository.save(_game('Aronnax'));

    final names = repository.loadAll().map((g) => g.humanPlayer.name);
    expect(names, ['Nemo', 'Aronnax']);
  });

  test('saving a stored game updates it in place', () async {
    final repository = GameRepository();
    final game = _game('Nemo');
    await repository.save(game);

    game.turn = 9;
    game.humanPlayer.resources[ResourceType.algae]!.amount = 1234;
    await repository.save(game);

    final loaded = repository.loadAll();
    expect(loaded, hasLength(1));
    expect(loaded.single.turn, 9);
    expect(loaded.single.humanPlayer.resources[ResourceType.algae]!.amount,
        1234);
  });

  test('delete removes the game at the given index', () async {
    final repository = GameRepository();
    await repository.save(_game('Nemo'));
    await repository.save(_game('Aronnax'));
    await repository.save(_game('Conseil'));

    await repository.delete(1);

    final names = repository.loadAll().map((g) => g.humanPlayer.name);
    expect(names, ['Nemo', 'Conseil']);
  });
}

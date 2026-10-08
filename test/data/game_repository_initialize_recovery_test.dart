import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:abyss/data/game_repository.dart';
import 'package:abyss/domain/game/game.dart';
import '../helpers/path_provider_mock.dart';

/// When the saved games box cannot be opened, [GameRepository.initialize]
/// wipes it and starts from an empty box instead of crashing at launch.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('abyss_repo_recover_');
    mockDocumentsDirectory(tempDir.path);
  });

  tearDown(() async {
    await Hive.close();
    clearDocumentsDirectoryMock();
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  test('recreates the games box when opening it fails', () async {
    // Holding the box open with another type makes the typed open throw.
    Hive.init(tempDir.path);
    final untyped = await Hive.openBox<dynamic>('games');
    await untyped.add('not a game');

    await GameRepository.initialize();

    expect(Hive.isBoxOpen('games'), isTrue);
    expect(() => Hive.box<Game>('games'), returnsNormally);
    expect(GameRepository().loadAll(), isEmpty);
  });
}

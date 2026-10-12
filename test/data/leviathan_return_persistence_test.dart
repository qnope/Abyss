import 'dart:io';

import 'package:abyss/data/game_repository.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:hive_ce/src/binary/binary_reader_impl.dart';
import 'package:hive_ce/src/binary/binary_writer_impl.dart';

import 'game_repository_fight_persistence_helper.dart';

const _boxName = 'games';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('abyss_leviathan_');
    Hive.init(tempDir.path);
    registerFightPersistenceAdapters();
    await Hive.openBox<Game>(_boxName);
  });

  tearDown(() async {
    await Hive.deleteBoxFromDisk(_boxName);
    await Hive.close();
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  Future<Game> reload(Game game) async {
    await GameRepository().save(game);
    await Hive.close();
    Hive.init(tempDir.path);
    await Hive.openBox<Game>(_boxName);
    return GameRepository().loadAll().single;
  }

  test('a scheduled counter-attack survives a save and a reload', () async {
    final game = Game.singlePlayer(Player(id: 'p', name: 'Persist'));
    game.leviathanReturn!.schedule(
      postName: 'abyssalRift',
      level: 1,
      at: GridPosition(x: 4, y: 6),
      capturedOn: 9,
    );

    final state = (await reload(game)).leviathanReturn!;

    expect(state.postName, 'abyssalRift');
    expect(state.level, 1);
    expect(state.at, GridPosition(x: 4, y: 6));
    expect(state.strikeTurn, 12);
    expect(state.isScheduled, isTrue);
  });

  test('a fresh game keeps it available after a reload', () async {
    final game = Game.singlePlayer(Player(id: 'p', name: 'Persist'));
    final state = (await reload(game)).leviathanReturn!;
    expect(state.isAvailable, isTrue);
  });

  test('a spent one stays spent', () async {
    final game = Game.singlePlayer(Player(id: 'p', name: 'Persist'));
    game.leviathanReturn!
      ..schedule(
        postName: 'abyssalRift',
        level: 1,
        at: GridPosition(x: 4, y: 6),
        capturedOn: 9,
      )
      ..end();
    final state = (await reload(game)).leviathanReturn!;
    expect(state.isAvailable, isFalse);
    expect(state.isScheduled, isFalse);
  });

  test('a game saved before the counter-attack loads without it', () {
    final writer =
        BinaryWriterImpl(Hive)
          ..writeByte(3)
          ..writeByte(0)
          ..write(<String, Player>{'p': Player(id: 'p', name: 'Old')})
          ..writeByte(1)
          ..write('p')
          ..writeByte(2)
          ..write(30);

    final game = GameAdapter().read(BinaryReaderImpl(writer.toBytes(), Hive));

    expect(game.turn, 30);
    expect(game.leviathanReturn, isNull);
  });
}

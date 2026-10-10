import 'dart:io';
import 'dart:math';

import 'package:abyss/data/game_repository.dart';
import 'package:abyss/domain/event/effects/wreck_effect.dart';
import 'package:abyss/domain/event/event_state.dart';
import 'package:abyss/domain/event/random_event_type.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:hive_ce/src/binary/binary_reader_impl.dart';
import 'package:hive_ce/src/binary/binary_writer_impl.dart';

import '../domain/event/effects/wreck_test_helper.dart';
import 'game_repository_fight_persistence_helper.dart';

const _boxName = 'games';

/// An [EventState] as the adapter wrote it before the wreck: fields 0-12.
BinaryWriterImpl _legacyEventState() {
  final writer = BinaryWriterImpl(Hive)..writeByte(13);
  final fields = <Object?>[
    20, null, null, RandomEventType.storm, RandomEventType.storm, //
    14, false, 4, null, null, null, null, null,
  ];
  for (var i = 0; i < fields.length; i++) {
    writer
      ..writeByte(i)
      ..write(fields[i]);
  }
  return writer;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('abyss_wreck_');
    Hive.init(tempDir.path);
    registerFightPersistenceAdapters();
    await Hive.openBox<Game>(_boxName);
  });

  tearDown(() async {
    await Hive.deleteBoxFromDisk(_boxName);
    await Hive.close();
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  test('a sunk wreck and its cell survive a save and a reload', () async {
    final player = wreckPlayer();
    final game = wreckGame(player);
    const WreckEffect().onDraw(game, player, turn: 12, random: Random(3));
    final at = player.eventState.wreckPosition!;
    await GameRepository().save(game);
    await Hive.close();

    Hive.init(tempDir.path);
    await Hive.openBox<Game>(_boxName);
    final loaded = GameRepository().loadAll().single;

    final state = loaded.humanPlayer.eventState;
    expect(state.wreckPosition, at);
    expect(state.wreckUntilTurn, 17);
    expect(
      loaded.currentMap.cellAt(at.x, at.y).content,
      CellContentType.wreck,
    );
  });

  test('an EventState saved before the wreck loads without one', () {
    final EventState decoded = EventStateAdapter().read(
      BinaryReaderImpl(_legacyEventState().toBytes(), Hive),
    );
    expect(decoded.active, RandomEventType.storm);
    expect(decoded.activeUntilTurn, 14);
    expect(decoded.eventsSeen, 4);
    expect(decoded.wreckPosition, isNull);
    expect(decoded.wreckUntilTurn, isNull);
  });
}

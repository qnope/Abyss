import 'dart:io';
import 'dart:typed_data';

import 'package:abyss/data/game_repository.dart';
import 'package:abyss/domain/event/random_event_type.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:hive_ce/src/binary/binary_reader_impl.dart';
import 'package:hive_ce/src/binary/binary_writer_impl.dart';

import 'game_repository_fight_persistence_helper.dart';

const _boxName = 'games';

/// Writes [player] as the adapter did before field 17 existed.
Uint8List _legacyBytes(Player player) {
  final writer =
      BinaryWriterImpl(Hive)
        ..writeByte(16)
        ..writeByte(0)
        ..write(player.name)
        ..writeByte(1)
        ..write(player.id)
        ..writeByte(2)
        ..write(player.baseX)
        ..writeByte(3)
        ..write(player.baseY)
        ..writeByte(4)
        ..write(player.resources)
        ..writeByte(5)
        ..write(player.buildings)
        ..writeByte(6)
        ..write(player.techBranches)
        ..writeByte(7)
        ..write(player.unitsPerLevel)
        ..writeByte(8)
        ..write(player.recruitedUnitTypes)
        ..writeByte(9)
        ..write(player.pendingExplorations)
        ..writeByte(10)
        ..write(player.revealedCellsPerLevel)
        ..writeByte(11)
        ..write(player.historyEntries)
        ..writeByte(13)
        ..write(player.pendingReinforcements)
        ..writeByte(14)
        ..write(player.raidState)
        ..writeByte(15)
        ..write(player.worksite)
        ..writeByte(16)
        ..write(player.volcanoState);
  return writer.toBytes();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('abyss_event_state_');
    Hive.init(tempDir.path);
    registerFightPersistenceAdapters();
    await Hive.openBox<Game>(_boxName);
  });

  tearDown(() async {
    await Hive.deleteBoxFromDisk(_boxName);
    await Hive.close();
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  test('a player saved before events loads with an empty EventState', () {
    final legacy = Player(name: 'Legacy', id: 'legacy-id', baseX: 3);
    final bytes = _legacyBytes(legacy);

    final decoded = PlayerAdapter().read(BinaryReaderImpl(bytes, Hive));

    expect(decoded.baseX, 3);
    expect(decoded.eventState.nextDrawTurn, isNull);
    expect(decoded.eventState.hasPending, isFalse);
    expect(decoded.eventState.active, isNull);
    expect(decoded.eventState.eventsSeen, 0);
  });

  test('a populated EventState survives a save and a reload', () async {
    final player = Player(name: 'Nemo', id: 'nemo-id');
    player.eventState
      ..setPending(RandomEventType.coldCurrent, 7)
      ..activate(RandomEventType.coldCurrent, untilTurn: 9)
      ..heating = true
      ..schedule(13);
    await GameRepository().save(Game.singlePlayer(player));
    await Hive.close();

    Hive.init(tempDir.path);
    await Hive.openBox<Game>(_boxName);
    final loaded = GameRepository().loadAll().single.humanPlayer.eventState;

    expect(loaded.nextDrawTurn, 13);
    expect(loaded.pending, RandomEventType.coldCurrent);
    expect(loaded.pendingTurn, 7);
    expect(loaded.lastDrawn, RandomEventType.coldCurrent);
    expect(loaded.active, RandomEventType.coldCurrent);
    expect(loaded.activeUntilTurn, 9);
    expect(loaded.heating, isTrue);
    expect(loaded.eventsSeen, 1);
  });

  test('every event type survives a save and a reload', () async {
    for (final type in RandomEventType.values) {
      final player = Player(name: type.name, id: type.name);
      player.eventState.activate(type, untilTurn: 3);
      await GameRepository().save(Game.singlePlayer(player));
    }
    await Hive.close();

    Hive.init(tempDir.path);
    await Hive.openBox<Game>(_boxName);
    final actives = [
      for (final game in GameRepository().loadAll())
        game.humanPlayer.eventState.active,
    ];

    expect(actives, RandomEventType.values);
  });
}

import 'dart:io';

import 'package:abyss/data/game_repository.dart';
import 'package:abyss/domain/event/event_state.dart';
import 'package:abyss/domain/event/random_event_type.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/resource/resource_type.dart';
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
    tempDir = await Directory.systemTemp.createTemp('abyss_event_offer_');
    Hive.init(tempDir.path);
    registerFightPersistenceAdapters();
    await Hive.openBox<Game>(_boxName);
  });

  tearDown(() async {
    await Hive.deleteBoxFromDisk(_boxName);
    await Hive.close();
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  test('an EventState saved before the offers loads without one', () {
    final writer =
        BinaryWriterImpl(Hive)
          ..writeByte(8)
          ..writeByte(0)
          ..write(13)
          ..writeByte(1)
          ..write(RandomEventType.survivors)
          ..writeByte(2)
          ..write(12)
          ..writeByte(3)
          ..write(RandomEventType.survivors)
          ..writeByte(4)
          ..write(null)
          ..writeByte(5)
          ..write(null)
          ..writeByte(6)
          ..write(false)
          ..writeByte(7)
          ..write(2);

    final decoded = EventStateAdapter().read(
      BinaryReaderImpl(writer.toBytes(), Hive),
    );

    expect(decoded.pending, RandomEventType.survivors);
    expect(decoded.eventsSeen, 2);
    expect(decoded.survivors, isNull);
    expect(decoded.tradeFrom, isNull);
    expect(decoded.tradeTo, isNull);
  });

  test('the survivors and the trade survive a save and a reload', () async {
    final player = Player(name: 'Nemo', id: 'nemo-id');
    player.eventState
      ..setPending(RandomEventType.caravan, 7)
      ..survivors = 5
      ..tradeFrom = ResourceType.ore
      ..tradeTo = ResourceType.algae;
    await GameRepository().save(Game.singlePlayer(player));
    await Hive.close();

    Hive.init(tempDir.path);
    await Hive.openBox<Game>(_boxName);
    final loaded = GameRepository().loadAll().single.humanPlayer.eventState;

    expect(loaded.survivors, 5);
    expect(loaded.tradeFrom, ResourceType.ore);
    expect(loaded.tradeTo, ResourceType.algae);
  });
}

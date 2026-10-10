import 'dart:io';

import 'package:abyss/data/game_repository.dart';
import 'package:abyss/domain/event/random_event_type.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/history/history_entry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

import 'game_repository_fight_persistence_helper.dart';

const _boxName = 'games';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('abyss_event_entry_');
    Hive.init(tempDir.path);
    registerFightPersistenceAdapters();
    await Hive.openBox<Game>(_boxName);
  });

  tearDown(() async {
    await Hive.deleteBoxFromDisk(_boxName);
    await Hive.close();
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  test('an event entry survives a save and a reload', () async {
    final player = Player(name: 'Nemo', id: 'nemo-id')..addHistoryEntry(
      EventEntry(
        turn: 14,
        type: RandomEventType.predators,
        accepted: false,
        defaulted: true,
      ),
    );
    await GameRepository().save(Game.singlePlayer(player));
    await Hive.close();

    Hive.init(tempDir.path);
    await Hive.openBox<Game>(_boxName);
    final loaded = GameRepository().loadAll().single.humanPlayer;
    final entry = loaded.historyEntries.whereType<EventEntry>().single;

    expect(entry.turn, 14);
    expect(entry.type, RandomEventType.predators);
    expect(entry.accepted, isFalse);
    expect(entry.defaulted, isTrue);
    expect(entry.subtitle, 'Option prudente, sans choix');
  });
}

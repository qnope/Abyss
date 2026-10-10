import 'dart:io';

import 'package:abyss/data/game_repository.dart';
import 'package:abyss/domain/event/event_state.dart';
import 'package:abyss/domain/event/random_event_type.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/domain/map/monster_family.dart';
import 'package:abyss/domain/map/monster_lair.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:hive_ce/src/binary/binary_reader_impl.dart';
import 'package:hive_ce/src/binary/binary_writer_impl.dart';

import '../domain/event/effects/predators_test_helper.dart';
import '../helpers/transition_fight_fixtures.dart';
import 'game_repository_fight_persistence_helper.dart';

const _boxName = 'games';

RaidEntry _entry({bool surprise = false}) => RaidEntry(
  turn: 14,
  victory: true,
  wave: predatorTestWave,
  fightResult: buildTestFight(playerWins: true),
  loot: const {ResourceType.coral: 40},
  pillaged: const {},
  defenders: const {UnitType.harpoonist: 6},
  survivorsIntact: const {UnitType.harpoonist: 6},
  wounded: const {},
  dead: const {},
  rampartLevel: 1,
  surprise: surprise,
);

/// The fields of [entry] as the adapter wrote them before [RaidEntry.surprise].
BinaryWriterImpl _legacyRaidEntry(RaidEntry entry) {
  final writer = BinaryWriterImpl(Hive)..writeByte(12);
  final fields = <int, Object?>{
    0: entry.turn,
    3: entry.subtitle,
    4: entry.victory,
    5: entry.wave,
    6: entry.fightResult,
    7: entry.loot,
    8: entry.pillaged,
    9: entry.defenders,
    10: entry.survivorsIntact,
    11: entry.wounded,
    12: entry.dead,
    13: entry.rampartLevel,
  };
  fields.forEach(
    (index, value) =>
        writer
          ..writeByte(index)
          ..write(value),
  );
  return writer;
}

/// An [EventState] as the adapter wrote it before the predators.
BinaryWriterImpl _legacyEventState() {
  final writer = BinaryWriterImpl(Hive)..writeByte(11);
  final fields = <Object?>[
    20, RandomEventType.predators, 21, RandomEventType.predators, null, //
    null, false, 3, null, null, null,
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
    tempDir = await Directory.systemTemp.createTemp('abyss_predators_');
    Hive.init(tempDir.path);
    registerFightPersistenceAdapters();
    await Hive.openBox<Game>(_boxName);
  });

  tearDown(() async {
    await Hive.deleteBoxFromDisk(_boxName);
    await Hive.close();
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  Future<Player> reload(Player player) async {
    await GameRepository().save(Game.singlePlayer(player));
    await Hive.close();
    Hive.init(tempDir.path);
    await Hive.openBox<Game>(_boxName);
    return GameRepository().loadAll().single.humanPlayer;
  }

  test('the predator wave and its fight survive a save and a reload', () async {
    final player = threatenedPlayer()..eventState.predatorsTurn = 12;
    player.addHistoryEntry(_entry(surprise: true));
    final loaded = await reload(player);

    final MonsterLair wave = loaded.eventState.predatorWave!;
    expect(wave.family, MonsterFamily.swarm);
    expect(wave.unitCount, 3);
    expect(wave.secondFamily, MonsterFamily.hunter);
    expect(wave.secondCount, 2);
    expect(loaded.eventState.predatorsTurn, 12);
    final entry = loaded.historyEntries.whereType<RaidEntry>().single;
    expect(entry.surprise, isTrue);
  });

  test('an EventState saved before the predators loads without a wave', () {
    final EventState decoded = EventStateAdapter().read(
      BinaryReaderImpl(_legacyEventState().toBytes(), Hive),
    );
    expect(decoded.pending, RandomEventType.predators);
    expect(decoded.eventsSeen, 3);
    expect(decoded.predatorWave, isNull);
    expect(decoded.predatorsTurn, isNull);
  });

  test('a raid saved before the predators is a plain raid', () {
    final RaidEntry decoded = RaidEntryAdapter().read(
      BinaryReaderImpl(_legacyRaidEntry(_entry()).toBytes(), Hive),
    );
    expect(decoded.surprise, isFalse);
    expect(decoded.victory, isTrue);
    expect(decoded.loot, {ResourceType.coral: 40});
  });
}

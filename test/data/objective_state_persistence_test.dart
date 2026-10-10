import 'dart:io';
import 'dart:typed_data';

import 'package:abyss/data/game_repository.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/objective/objective_id.dart';
import 'package:abyss/domain/objective/objective_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:hive_ce/src/binary/binary_reader_impl.dart';
import 'package:hive_ce/src/binary/binary_writer_impl.dart';

import 'game_repository_fight_persistence_helper.dart';

const _boxName = 'games';

/// Writes [player] as the adapter did before field 18 existed.
Uint8List _legacyBytes(Player player) {
  final writer = BinaryWriterImpl(Hive)..writeByte(17);
  final fields = <dynamic>[
    player.name, player.id, player.baseX, player.baseY, player.resources,
    player.buildings, player.techBranches, player.unitsPerLevel,
    player.recruitedUnitTypes, player.pendingExplorations,
    player.revealedCellsPerLevel, player.historyEntries,
  ];
  for (var i = 0; i < fields.length; i++) {
    writer
      ..writeByte(i)
      ..write(fields[i]);
  }
  writer
    ..writeByte(13)
    ..write(player.pendingReinforcements)
    ..writeByte(14)
    ..write(player.raidState)
    ..writeByte(15)
    ..write(player.worksite)
    ..writeByte(16)
    ..write(player.volcanoState)
    ..writeByte(17)
    ..write(player.eventState);
  return writer.toBytes();
}

Future<Game> _reload(Directory dir, Game game) async {
  await GameRepository().save(game);
  await Hive.close();
  Hive.init(dir.path);
  await Hive.openBox<Game>(_boxName);
  return GameRepository().loadAll().single;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('abyss_objective_state_');
    Hive.init(tempDir.path);
    registerFightPersistenceAdapters();
    await Hive.openBox<Game>(_boxName);
  });

  tearDown(() async {
    await Hive.deleteBoxFromDisk(_boxName);
    await Hive.close();
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  test('an ObjectiveState survives its adapter', () {
    final state = ObjectiveState(tutorialEnabled: true)
      ..complete(ObjectiveId.mines)
      ..complete(ObjectiveId.hqLevel1);
    final writer = BinaryWriterImpl(Hive)..write(state);

    final decoded =
        BinaryReaderImpl(writer.toBytes(), Hive).read() as ObjectiveState;

    expect(decoded.completed, [ObjectiveId.mines, ObjectiveId.hqLevel1]);
    expect(decoded.tutorialEnabled, isTrue);
  });

  test('a player carries its objectives through a save and a reload', () async {
    final player = Player(name: 'Nemo', id: 'nemo-id')
      ..savedObjectiveState = (ObjectiveState(tutorialEnabled: true)
        ..complete(ObjectiveId.hqLevel1));

    final loaded = (await _reload(tempDir, Game.singlePlayer(player)))
        .humanPlayer
        .savedObjectiveState!;

    expect(loaded.completed, [ObjectiveId.hqLevel1]);
    expect(loaded.tutorialEnabled, isTrue);
  });

  test('a player saved before the objectives decodes without state', () {
    final legacy = Player(name: 'Legacy', id: 'legacy-id', baseX: 3);

    final decoded = PlayerAdapter().read(
      BinaryReaderImpl(_legacyBytes(legacy), Hive),
    );

    expect(decoded.baseX, 3);
    expect(decoded.savedObjectiveState, isNull);
  });

  test('loading an old save checks the objectives met, tutorial off', () async {
    final player = Player(name: 'Legacy', id: 'legacy-id')
      ..savedObjectiveState = null;
    player.buildings[BuildingType.headquarters]!.level = 1;

    final loaded = (await _reload(tempDir, Game.singlePlayer(player)))
        .humanPlayer
        .savedObjectiveState!;

    expect(loaded.completed, [ObjectiveId.hqLevel1]);
    expect(loaded.tutorialEnabled, isFalse);
  });
}

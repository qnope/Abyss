import 'dart:io';

import 'package:abyss/data/game_repository.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/raid/announced_attack.dart';
import 'package:abyss/domain/raid/raid_state.dart';
import 'package:abyss/domain/unit/unit_type.dart';
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
    tempDir = await Directory.systemTemp.createTemp('abyss_announced_');
    Hive.init(tempDir.path);
    registerFightPersistenceAdapters();
    await Hive.openBox<Game>(_boxName);
  });

  tearDown(() async {
    await Hive.deleteBoxFromDisk(_boxName);
    await Hive.close();
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  test('an announced attack survives a save and a reload', () async {
    final player = Player(id: 'p', name: 'Persist');
    player.raidState.attacks.add(
      AnnouncedAttack(
        attackerId: 'faction-pearlOrder',
        units: const {UnitType.harpoonist: 12, UnitType.guardian: 4},
        arrivalTurn: 21,
        seed: 987654,
      ),
    );
    await GameRepository().save(Game.singlePlayer(player));
    await Hive.close();
    Hive.init(tempDir.path);
    await Hive.openBox<Game>(_boxName);

    final attack =
        GameRepository().loadAll().single.humanPlayer.raidState.attacks.single;

    expect(attack.attackerId, 'faction-pearlOrder');
    expect(attack.units, {UnitType.harpoonist: 12, UnitType.guardian: 4});
    expect(attack.arrivalTurn, 21);
    expect(attack.seed, 987654);
  });

  test('a raid state saved before the attacks loads without any', () {
    final writer =
        BinaryWriterImpl(Hive)
          ..writeByte(2)
          ..writeByte(0)
          ..write(7)
          ..writeByte(4)
          ..write(1);

    final state = RaidStateAdapter().read(
      BinaryReaderImpl(writer.toBytes(), Hive),
    );

    expect(state.noise, 7);
    expect(state.lostInARow, 1);
    expect(state.attacks, isEmpty);
  });
}

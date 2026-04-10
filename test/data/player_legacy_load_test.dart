import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive/src/binary/binary_reader_impl.dart';
import 'package:hive/src/binary/binary_writer_impl.dart';

import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/resource/resource_type.dart';

import 'game_repository_fight_persistence_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('abyss_player_legacy_');
    Hive.init(tempDir.path);
    registerFightPersistenceAdapters();
  });

  tearDown(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test(
    'PlayerAdapter.read yields empty historyEntries for legacy payloads '
    'missing field 11',
    () {
      // Build a Player and write only its pre-history fields (0..10) so the
      // payload looks like a savegame produced before historyEntries existed.
      final legacy = Player(
        name: 'Legacy',
        id: 'legacy-id',
        baseX: 3,
        baseY: 4,
      );
      legacy.resources[ResourceType.algae]!.amount = 123;

      final writer = BinaryWriterImpl(Hive);
      // 11 fields written (0..10), mimicking the old generated adapter.
      writer
        ..writeByte(11)
        ..writeByte(0)
        ..write(legacy.name)
        ..writeByte(1)
        ..write(legacy.id)
        ..writeByte(2)
        ..write(legacy.baseX)
        ..writeByte(3)
        ..write(legacy.baseY)
        ..writeByte(4)
        ..write(legacy.resources)
        ..writeByte(5)
        ..write(legacy.buildings)
        ..writeByte(6)
        ..write(legacy.techBranches)
        ..writeByte(7)
        ..write(legacy.unitsPerLevel)
        ..writeByte(8)
        ..write(legacy.recruitedUnitTypes)
        ..writeByte(9)
        ..write(legacy.pendingExplorations)
        ..writeByte(10)
        ..write(legacy.revealedCellsPerLevel);

      final bytes = writer.toBytes();
      final reader = BinaryReaderImpl(bytes, Hive);

      final decoded = PlayerAdapter().read(reader);

      expect(decoded.name, 'Legacy');
      expect(decoded.id, 'legacy-id');
      expect(decoded.baseX, 3);
      expect(decoded.baseY, 4);
      expect(decoded.resources[ResourceType.algae]!.amount, 123);
      expect(
        decoded.historyEntries,
        isEmpty,
        reason: 'Legacy payloads must decode with an empty history list.',
      );
      // The historyEntries list must be mutable so FIFO append works.
      expect(() => decoded.historyEntries.add, returnsNormally);
    },
  );
}

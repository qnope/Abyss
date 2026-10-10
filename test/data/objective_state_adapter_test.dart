import 'package:abyss/domain/objective/objective_id.dart';
import 'package:abyss/domain/objective/objective_state.dart';
import 'package:abyss/domain/objective/tip/tip_id.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:hive_ce/src/binary/binary_reader_impl.dart';
import 'package:hive_ce/src/binary/binary_writer_impl.dart';

import 'game_repository_fight_persistence_helper.dart';

/// The [ObjectiveState] adapter, on its own and on the payloads written
/// before its later fields.
void main() {
  setUpAll(registerFightPersistenceAdapters);

  test('an ObjectiveState survives its adapter', () {
    final state =
        ObjectiveState(tutorialEnabled: true, tipsEnabled: true)
          ..complete(ObjectiveId.mines)
          ..complete(ObjectiveId.hqLevel1)
          ..markSeen(TipId.raidAnnounced)
          ..markSeen(TipId.noiseGauge);
    final writer = BinaryWriterImpl(Hive)..write(state);

    final decoded =
        BinaryReaderImpl(writer.toBytes(), Hive).read() as ObjectiveState;

    expect(decoded.completed, [ObjectiveId.mines, ObjectiveId.hqLevel1]);
    expect(decoded.tutorialEnabled, isTrue);
    expect(decoded.tipsEnabled, isTrue);
    expect(decoded.seenTips, [TipId.raidAnnounced, TipId.noiseGauge]);
  });

  test('a state saved before the tip cards decodes with none seen', () {
    final writer =
        BinaryWriterImpl(Hive)
          ..writeByte(3)
          ..writeByte(0)
          ..write([ObjectiveId.hqLevel1])
          ..writeByte(1)
          ..write(true)
          ..writeByte(2)
          ..write(true);

    final decoded = ObjectiveStateAdapter().read(
      BinaryReaderImpl(writer.toBytes(), Hive),
    );

    expect(decoded.tipsEnabled, isTrue);
    expect(decoded.seenTips, isEmpty);
    expect(decoded.hasSeen(TipId.noiseGauge), isFalse);
    decoded.markSeen(TipId.noiseGauge);
    expect(decoded.seenTips, [TipId.noiseGauge]);
  });

  test('a state saved before the tips decodes with the tips off', () {
    final writer =
        BinaryWriterImpl(Hive)
          ..writeByte(2)
          ..writeByte(0)
          ..write([ObjectiveId.hqLevel1])
          ..writeByte(1)
          ..write(true);

    final decoded = ObjectiveStateAdapter().read(
      BinaryReaderImpl(writer.toBytes(), Hive),
    );

    expect(decoded.completed, [ObjectiveId.hqLevel1]);
    expect(decoded.tutorialEnabled, isTrue);
    expect(decoded.tipsEnabled, isFalse);
  });
}

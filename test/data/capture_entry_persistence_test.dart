import 'package:abyss/domain/history/history_entry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:hive_ce/src/binary/binary_reader_impl.dart';
import 'package:hive_ce/src/binary/binary_writer_impl.dart';

import '../helpers/transition_fight_fixtures.dart';
import 'game_repository_fight_persistence_helper.dart';

/// [entry] written then read back by its adapter; when [legacy], written
/// without [CaptureEntry.captured], as older versions did.
CaptureEntry _roundTrip(CaptureEntry entry, {bool legacy = false}) {
  final writer = BinaryWriterImpl(Hive);
  if (legacy) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(entry.turn)
      ..writeByte(4)
      ..write(entry.transitionBaseName)
      ..writeByte(5)
      ..write(entry.fightResult);
  } else {
    CaptureEntryAdapter().write(writer, entry);
  }
  return CaptureEntryAdapter().read(BinaryReaderImpl(writer.toBytes(), Hive));
}

void main() {
  setUpAll(registerFightPersistenceAdapters);

  final fell = CaptureEntry(
    turn: 4,
    transitionBaseName: 'faille:0',
    fightResult: buildTestFight(playerWins: true),
    captured: false,
  );

  test('a victory where the admiral fell is saved as not captured', () {
    expect(_roundTrip(fell).captured, isFalse);
  });

  test('a capture saved before the field reads as captured', () {
    final entry = _roundTrip(fell, legacy: true);
    expect(entry.captured, isTrue);
    expect(entry.transitionBaseName, 'faille:0');
  });
}

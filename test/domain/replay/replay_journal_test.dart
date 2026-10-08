import 'dart:io';

import 'package:abyss/domain/action/end_turn_action.dart';
import 'package:abyss/domain/action/recruit_unit_action.dart';
import 'package:abyss/domain/replay/replay_journal.dart';
import 'package:abyss/domain/replay/seeded_random.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

void main() {
  group('ReplayJournal', () {
    test('notes moves per turn and the dice of each end of turn', () {
      final journal =
          ReplayJournal(mapSeed: 1, playerName: 'Nemo')
            ..record(
              2,
              RecruitUnitAction(unitType: UnitType.scout, quantity: 3),
            )
            ..record(2, EndTurnAction(random: SeededRandom(8)));

      expect(journal.actionsOf(2), [
        {'do': 'recruit', 'unit': 'scout', 'count': 3},
      ]);
      expect(journal.endTurnSeeds, {2: 8});
      expect(journal.exact, isTrue);
    });

    test('is no longer exact once a turn ends on unrecorded dice', () {
      final journal = ReplayJournal(mapSeed: 1, playerName: 'Nemo')
        ..record(1, EndTurnAction());

      expect(journal.exact, isFalse);
      expect(journal.endTurnSeeds, isEmpty);
    });

    test('survives a save and a reload', () async {
      final Directory dir = await Directory.systemTemp.createTemp('replay_');
      Hive.init(dir.path);
      if (!Hive.isAdapterRegistered(45)) {
        Hive.registerAdapter(ReplayJournalAdapter());
      }
      final Box<ReplayJournal> box = await Hive.openBox('replay_journal');
      await box.put(
        'j',
        ReplayJournal(mapSeed: 5, playerName: 'Nemo')
          ..record(1, RecruitUnitAction(unitType: UnitType.scout, quantity: 1))
          ..record(1, EndTurnAction(random: SeededRandom(4))),
      );
      await box.close();

      final Box<ReplayJournal> reopened = await Hive.openBox('replay_journal');
      final ReplayJournal journal =
          reopened.get('j')!..record(
            2,
            RecruitUnitAction(unitType: UnitType.scout, quantity: 2),
          );

      expect(journal.mapSeed, 5);
      expect(journal.actionsOf(1).single['count'], 1);
      expect(journal.actionsOf(2).single['count'], 2);
      expect(journal.endTurnSeeds, {1: 4});
      await Hive.deleteFromDisk();
      dir.deleteSync(recursive: true);
    });
  });
}

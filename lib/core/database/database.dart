import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(tables: [
  PlayerTable,
  ColoniesTable,
  BuildingsTable,
  TroopsTable,
  WorldMapTable,
  CombatLogTable,
  MessagesTable,
  DiplomacyTable,
  ResearchTable,
  QuestsTable,
])
class GameDatabase extends _$GameDatabase {
  GameDatabase() : super(_openConnection());

  GameDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
          await customStatement('PRAGMA journal_mode=WAL');
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'abysses.db'));
    return NativeDatabase.createInBackground(file);
  });
}

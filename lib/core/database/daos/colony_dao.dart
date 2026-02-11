import 'package:drift/drift.dart';

import '../database.dart';
import '../tables.dart';

part 'colony_dao.g.dart';

@DriftAccessor(tables: [ColoniesTable])
class ColonyDao extends DatabaseAccessor<GameDatabase> with _$ColonyDaoMixin {
  ColonyDao(super.db);

  Future<List<ColoniesTableData>> getAllColonies() =>
      select(coloniesTable).get();

  Stream<List<ColoniesTableData>> watchAllColonies() =>
      select(coloniesTable).watch();

  Future<ColoniesTableData?> getColonyById(int id) =>
      (select(coloniesTable)..where((c) => c.id.equals(id)))
          .getSingleOrNull();

  Future<List<ColoniesTableData>> getPlayerColonies() =>
      (select(coloniesTable)..where((c) => c.ownerType.equals('player')))
          .get();

  Future<List<ColoniesTableData>> getDiscoveredColonies() =>
      (select(coloniesTable)
            ..where((c) => c.discoveredByPlayer.equals(true)))
          .get();

  Future<int> insertColony(ColoniesTableCompanion colony) =>
      into(coloniesTable).insert(colony);

  Future<bool> updateColony(ColoniesTableCompanion colony) =>
      update(coloniesTable).replace(colony);

  Future<int> deleteColony(int id) =>
      (delete(coloniesTable)..where((c) => c.id.equals(id))).go();
}

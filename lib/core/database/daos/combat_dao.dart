import 'package:drift/drift.dart';

import '../database.dart';
import '../tables.dart';

part 'combat_dao.g.dart';

@DriftAccessor(tables: [CombatLogTable])
class CombatDao extends DatabaseAccessor<GameDatabase> with _$CombatDaoMixin {
  CombatDao(super.db);

  Future<List<CombatLogTableData>> getRecentCombats({int limit = 50}) =>
      (select(combatLogTable)
            ..orderBy([(t) => OrderingTerm.desc(t.timestamp)])
            ..limit(limit))
          .get();

  Stream<List<CombatLogTableData>> watchRecentCombats({int limit = 20}) =>
      (select(combatLogTable)
            ..orderBy([(t) => OrderingTerm.desc(t.timestamp)])
            ..limit(limit))
          .watch();

  Future<List<CombatLogTableData>> getCombatsForColony(int colonyId) =>
      (select(combatLogTable)
            ..where((c) =>
                c.attackerId.equals(colonyId) |
                c.defenderId.equals(colonyId))
            ..orderBy([(t) => OrderingTerm.desc(t.timestamp)]))
          .get();

  Future<int> insertCombatLog(CombatLogTableCompanion log) =>
      into(combatLogTable).insert(log);
}

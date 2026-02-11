import 'package:drift/drift.dart';

import '../database.dart';
import '../tables.dart';

part 'player_dao.g.dart';

@DriftAccessor(tables: [PlayerTable])
class PlayerDao extends DatabaseAccessor<GameDatabase> with _$PlayerDaoMixin {
  PlayerDao(super.db);

  Future<PlayerTableData?> getPlayer() =>
      select(playerTable).getSingleOrNull();

  Stream<PlayerTableData?> watchPlayer() =>
      select(playerTable).watchSingleOrNull();

  Future<int> insertPlayer(PlayerTableCompanion player) =>
      into(playerTable).insert(player);

  Future<bool> updatePlayer(PlayerTableCompanion player) =>
      update(playerTable).replace(player);
}

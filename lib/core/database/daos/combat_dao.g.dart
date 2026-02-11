// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'combat_dao.dart';

// ignore_for_file: type=lint
mixin _$CombatDaoMixin on DatabaseAccessor<GameDatabase> {
  $ColoniesTableTable get coloniesTable => attachedDatabase.coloniesTable;
  $CombatLogTableTable get combatLogTable => attachedDatabase.combatLogTable;
  CombatDaoManager get managers => CombatDaoManager(this);
}

class CombatDaoManager {
  final _$CombatDaoMixin _db;
  CombatDaoManager(this._db);
  $$ColoniesTableTableTableManager get coloniesTable =>
      $$ColoniesTableTableTableManager(_db.attachedDatabase, _db.coloniesTable);
  $$CombatLogTableTableTableManager get combatLogTable =>
      $$CombatLogTableTableTableManager(
        _db.attachedDatabase,
        _db.combatLogTable,
      );
}

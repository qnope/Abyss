// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'colony_dao.dart';

// ignore_for_file: type=lint
mixin _$ColonyDaoMixin on DatabaseAccessor<GameDatabase> {
  $ColoniesTableTable get coloniesTable => attachedDatabase.coloniesTable;
  ColonyDaoManager get managers => ColonyDaoManager(this);
}

class ColonyDaoManager {
  final _$ColonyDaoMixin _db;
  ColonyDaoManager(this._db);
  $$ColoniesTableTableTableManager get coloniesTable =>
      $$ColoniesTableTableTableManager(_db.attachedDatabase, _db.coloniesTable);
}

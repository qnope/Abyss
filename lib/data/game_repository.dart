import 'package:hive_ce_flutter/hive_flutter.dart';
import '../domain/game/game.dart';
import '../hive_registrar.g.dart';

class GameRepository {
  static const _boxName = 'games';

  static Future<void> initialize() async {
    await Hive.initFlutter();
    Hive.registerAdapters();
    try {
      await Hive.openBox<Game>(_boxName);
    } catch (_) {
      await Hive.deleteBoxFromDisk(_boxName);
      await Hive.openBox<Game>(_boxName);
    }
  }

  Box<Game> get _box => Hive.box<Game>(_boxName);

  Future<void> save(Game game) async {
    if (game.isInBox) {
      await game.save();
    } else {
      await _box.add(game);
    }
  }

  List<Game> loadAll() {
    return _box.values.toList();
  }

  Future<void> delete(int index) async {
    await _box.deleteAt(index);
  }
}

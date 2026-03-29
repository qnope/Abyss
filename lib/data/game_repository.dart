import 'package:hive_flutter/hive_flutter.dart';
import '../domain/game.dart';
import '../domain/player.dart';
import '../domain/resource.dart';
import '../domain/resource_type.dart';

class GameRepository {
  static const _boxName = 'games';

  static Future<void> initialize() async {
    await Hive.initFlutter();
    Hive.registerAdapter(ResourceTypeAdapter());
    Hive.registerAdapter(ResourceAdapter());
    Hive.registerAdapter(PlayerAdapter());
    Hive.registerAdapter(GameAdapter());
    await Hive.openBox<Game>(_boxName);
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

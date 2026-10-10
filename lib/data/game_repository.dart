import 'package:hive_ce_flutter/hive_flutter.dart';
import '../domain/game/game.dart';
import '../domain/objective/objective_migration.dart';
import '../hive_registrar.g.dart';

class GameRepository {
  static const _boxName = 'games';

  /// Tells the time each save is stamped with.
  final DateTime Function() _now;

  GameRepository({DateTime Function() now = DateTime.now}) : _now = now;

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

  /// Stores [game], stamping it as last played now.
  Future<void> save(Game game) async {
    game.savedLastPlayedAt = _now();
    if (game.isInBox) {
      await game.save();
    } else {
      await _box.add(game);
    }
  }

  /// Every saved game, those saved before the objectives migrated to
  /// them.
  List<Game> loadAll() {
    final games = _box.values.toList();
    games.forEach(ObjectiveMigration.migrate);
    return games;
  }

  /// Removes [game] from the saves; does nothing if it was never stored.
  Future<void> deleteGame(Game game) async {
    if (game.isInBox) await game.delete();
  }
}

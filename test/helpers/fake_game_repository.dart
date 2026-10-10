import 'package:abyss/data/game_repository.dart';
import 'package:abyss/domain/game/game.dart';

class FakeGameRepository extends GameRepository {
  final List<Game> _games = [];
  int saveCallCount = 0;

  void addGame(Game game) => _games.add(game);

  @override
  Future<void> save(Game game) async {
    saveCallCount++;
    _games.add(game);
  }

  @override
  List<Game> loadAll() => List.of(_games);

  @override
  Future<void> deleteGame(Game game) async => _games.remove(game);
}

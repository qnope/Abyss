import 'package:abyss/data/game_repository.dart';
import 'package:abyss/domain/game.dart';

class FakeGameRepository extends GameRepository {
  final List<Game> _games = [];

  void addGame(Game game) => _games.add(game);

  @override
  Future<void> save(Game game) async => _games.add(game);

  @override
  List<Game> loadAll() => List.of(_games);

  @override
  Future<void> delete(int index) async => _games.removeAt(index);
}

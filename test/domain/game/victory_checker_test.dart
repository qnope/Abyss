import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/game_status.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/game/victory_checker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Player _player({
    required String id,
    required String name,
    int kernelLevel = 0,
  }) {
    return Player(
      id: id,
      name: name,
      buildings: {
        BuildingType.volcanicKernel: Building(
          type: BuildingType.volcanicKernel,
          level: kernelLevel,
        ),
      },
    );
  }

  Game _game({
    required Player human,
    List<Player> others = const [],
    GameStatus status = GameStatus.playing,
  }) {
    final players = {human.id: human};
    for (final p in others) {
      players[p.id] = p;
    }
    return Game(
      humanPlayerId: human.id,
      players: players,
      status: status,
    );
  }

  group('VictoryChecker', () {
    test('returns null when no player has kernel at level 10', () {
      final human = _player(id: 'h', name: 'Human', kernelLevel: 5);
      final game = _game(human: human);
      expect(VictoryChecker.check(game), isNull);
    });

    test('returns victory when human kernel is level 10', () {
      final human = _player(id: 'h', name: 'Human', kernelLevel: 10);
      final game = _game(human: human);
      expect(VictoryChecker.check(game), GameStatus.victory);
    });

    test('returns defeat when non-human kernel is level 10', () {
      final human = _player(id: 'h', name: 'Human', kernelLevel: 3);
      final enemy = _player(id: 'e', name: 'Enemy', kernelLevel: 10);
      final game = _game(human: human, others: [enemy]);
      expect(VictoryChecker.check(game), GameStatus.defeat);
    });

    test('returns null when game status is freePlay', () {
      final human = _player(id: 'h', name: 'Human', kernelLevel: 10);
      final game = _game(human: human, status: GameStatus.freePlay);
      expect(VictoryChecker.check(game), isNull);
    });

    test('returns null when game status is already victory', () {
      final human = _player(id: 'h', name: 'Human', kernelLevel: 10);
      final game = _game(human: human, status: GameStatus.victory);
      expect(VictoryChecker.check(game), isNull);
    });

    test('returns null when kernel is level 9', () {
      final human = _player(id: 'h', name: 'Human', kernelLevel: 9);
      final game = _game(human: human);
      expect(VictoryChecker.check(game), isNull);
    });
  });
}

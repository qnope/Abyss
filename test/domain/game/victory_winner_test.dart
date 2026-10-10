import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/game/victory_checker.dart';
import 'package:flutter_test/flutter_test.dart';

Player _player(String id, int kernel) => Player(
  id: id,
  name: 'Name $id',
  buildings: {
    BuildingType.volcanicKernel: Building(
      type: BuildingType.volcanicKernel,
      level: kernel,
    ),
  },
);

void main() {
  test('the winner is whoever raised the kernel to level 10', () {
    final human = _player('h', 4);
    final faction = _player('f', 10);
    final game = Game(
      humanPlayerId: 'h',
      players: {'h': human, 'f': faction},
    );

    expect(VictoryChecker.winnerOf(game), faction);
  });

  test('nobody wins before the kernel reaches level 10', () {
    final human = _player('h', 9);
    final faction = _player('f', 7);
    final game = Game(
      humanPlayerId: 'h',
      players: {'h': human, 'f': faction},
    );

    expect(VictoryChecker.winnerOf(game), isNull);
  });
}

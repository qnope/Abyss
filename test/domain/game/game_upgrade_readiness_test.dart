import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/game_upgrade_readiness.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const hq = BuildingType.headquarters, farm = BuildingType.algaeFarm;

  ({Game game, Player player}) scenario() {
    final player = Player(id: 'nemo', name: 'Nemo')
      ..buildings[hq]!.level = 2
      ..buildings[farm]!.level = 1;
    return (
      game: Game(humanPlayerId: player.id, players: {player.id: player}),
      player: player,
    );
  }

  test('reads the readiness of every building of the player', () {
    final s = scenario();
    final readiness = s.game.upgradeReadinessesOf(s.player);
    expect(readiness.keys.toSet(), BuildingType.values.toSet());
    expect(readiness[farm]!.isReady, isTrue);
    expect(readiness[BuildingType.descentModule]!.isLocked, isTrue);
  });

  test('a worksite already used this turn leaves nothing ready', () {
    final s = scenario();
    s.player.worksite.upgrades = 1;
    final readiness = s.game.upgradeReadinessesOf(s.player);
    expect(readiness.values.where((r) => r.isReady), isEmpty);
  });

  test('one building reads the same as the whole base', () {
    final s = scenario();
    expect(s.game.upgradeReadinessOf(s.player, farm).isReady, isTrue);
  });
}

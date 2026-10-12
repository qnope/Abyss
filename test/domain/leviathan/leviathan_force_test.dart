import 'package:abyss/domain/fight/combat_side.dart';
import 'package:abyss/domain/fight/guardian_factory.dart';
import 'package:abyss/domain/game/difficulty.dart';
import 'package:abyss/domain/game/game_factory.dart';
import 'package:abyss/domain/leviathan/leviathan_force.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a Léviathan and four Sentinelles, attacking', () {
    final force = LeviathanForce.combatants();
    expect(LeviathanForce.sentinels, 4);
    expect(force, hasLength(1 + LeviathanForce.sentinels));
    expect(force.every((c) => c.side == CombatSide.player), isTrue);
    expect(force.first.typeKey, LeviathanForce.leviathanKey);
    expect(force.first.isBoss, isTrue);
    expect(
      force.skip(1).every((c) => c.typeKey == LeviathanForce.sentinelKey),
      isTrue,
    );
  });

  test('the guardians of a Faille at full strength by default', () {
    final faille = GuardianFactory.forFaille();
    final force = LeviathanForce.combatants();
    expect(force.first.maxHp, faille.first.maxHp);
    expect(force.first.atk, faille.first.atk);
    expect(force.last.maxHp, faille.last.maxHp);
    expect(force.last.def, faille.last.def);
  });

  test('scaled like the other monsters of the game', () {
    final game = GameFactory.newGame(
      playerName: 'Nemo',
      mapSeed: 7,
      factionCount: 2,
      difficulty: Difficulty.hard,
    );
    final int percent = Difficulty.hard.monsterPercentFor(
      faction: false,
      factions: 2,
    );
    expect(LeviathanForce.percentOf(game), percent);
    final force = LeviathanForce.of(game);
    final faille = GuardianFactory.forFaille();
    expect(force.first.maxHp, faille.first.maxHp * percent ~/ 100);
    expect(force.first.atk, faille.first.atk * percent ~/ 100);
    expect(force.last.maxHp, faille.last.maxHp * percent ~/ 100);
    expect(force.last.def, faille.last.def);
  });

  test('counts the force by kind', () {
    expect(LeviathanForce.counts, {
      LeviathanForce.leviathanKey: 1,
      LeviathanForce.sentinelKey: LeviathanForce.sentinels,
    });
  });
}

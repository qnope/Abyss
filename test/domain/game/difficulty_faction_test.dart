import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/difficulty.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/turn/player_turn_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

/// Algae the default base earns in one end of turn.
int algaeGained(Difficulty difficulty, {required bool faction}) {
  final player = Player(name: 'p');
  player.buildings[BuildingType.algaeFarm] = Building(
    type: BuildingType.algaeFarm,
    level: 5,
  );
  final before = player.resources[ResourceType.algae]!.amount;
  PlayerTurnResolver.resolve(
    player,
    1,
    difficulty: difficulty,
    isFaction: faction,
  );
  return player.resources[ResourceType.algae]!.amount - before;
}

void main() {
  test('factions produce 90, 100 and 110 % by difficulty', () {
    expect(Difficulty.easy.factionPercent, 90);
    expect(Difficulty.normal.factionPercent, 100);
    expect(Difficulty.hard.factionPercent, 110);
  });

  test('the production of a faction moves against the human one', () {
    final normal = algaeGained(Difficulty.normal, faction: true);
    expect(normal, greaterThan(0));
    expect(
      algaeGained(Difficulty.easy, faction: true),
      lessThan(algaeGained(Difficulty.easy, faction: false)),
    );
    expect(
      algaeGained(Difficulty.hard, faction: true),
      greaterThan(algaeGained(Difficulty.hard, faction: false)),
    );
    expect(algaeGained(Difficulty.easy, faction: true), lessThan(normal));
    expect(algaeGained(Difficulty.hard, faction: true), greaterThan(normal));
  });

  test('the human production keeps its own levers', () {
    final easy = algaeGained(Difficulty.easy, faction: false);
    final normal = algaeGained(Difficulty.normal, faction: false);
    final hard = algaeGained(Difficulty.hard, faction: false);

    expect(easy, greaterThan(normal));
    expect(hard, lessThan(normal));
    expect(normal, algaeGained(Difficulty.normal, faction: true));
  });

  test('energy and pearls are not scaled for a faction either', () {
    final production = Difficulty.hard.scaleProduction({
      ResourceType.energy: 100,
      ResourceType.pearl: 100,
      ResourceType.coral: 100,
    }, faction: true);

    expect(production[ResourceType.energy], 100);
    expect(production[ResourceType.pearl], 100);
    expect(production[ResourceType.coral], 110);
  });
}

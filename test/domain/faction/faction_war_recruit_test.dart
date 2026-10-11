import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/faction/faction_personality.dart';
import 'package:abyss/domain/faction/faction_traits.dart';
import 'package:abyss/domain/faction/faction_war_recruit.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/game_factory.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/replay/seeded_random.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/script/script_turn.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

Player _armed(Game game, {required bool seesHuman}) {
  final Player me = game.players[game.factions.first.id]!;
  me.buildings[BuildingType.barracks]!.level = 5;
  for (final r in ResourceType.values) {
    me.resources[r]!.amount = 5000;
  }
  if (seesHuman) {
    final Player human = game.humanPlayer;
    me.addRevealedCell(1, GridPosition(x: human.baseX, y: human.baseY));
  }
  return me;
}

ScriptTurn _turn(Game game, Player me) =>
    ScriptTurn(game: game, player: me, random: SeededRandom(1), log: []);

int _harpoonists(Player me) => me.unitsOnLevel(1)[UnitType.harpoonist]!.count;

void main() {
  Game newGame(FactionPersonality p) =>
      GameFactory.newGame(playerName: 'Nemo', mapSeed: 3, personalities: [p]);

  test('a faction that knows a rival arms with its own mix of units', () {
    const p = FactionPersonality.wreckPillagers;
    final game = newGame(p);
    final me = _armed(game, seesHuman: true);
    FactionWarRecruit.play(_turn(game, me), FactionTraits.of(p));
    expect(_harpoonists(me), greaterThan(0));
    expect(me.unitsOnLevel(1)[UnitType.saboteur]!.count, greaterThan(0));
  });

  test('a faction alone keeps its stocks for the race', () {
    const p = FactionPersonality.wreckPillagers;
    final game = newGame(p);
    final me = _armed(game, seesHuman: false);
    FactionWarRecruit.play(_turn(game, me), FactionTraits.of(p));
    expect(_harpoonists(me), 0);
  });

  test('it keeps what it spends within its war share of the stocks', () {
    const p = FactionPersonality.pearlOrder;
    final game = newGame(p);
    final me = _armed(game, seesHuman: true);
    FactionWarRecruit.play(_turn(game, me), FactionTraits.of(p));
    expect(me.resources[ResourceType.coral]!.amount, greaterThan(4000));
  });
}

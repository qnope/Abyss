import 'dart:math';

import 'package:abyss/domain/action/end_turn_action.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/announce_attack_helper.dart';
import '../../../helpers/base_attack_helper.dart';
import '../../../helpers/two_player_game.dart';

void endTurn(TwoPlayerGame two) => EndTurnAction(
  random: Random(1),
  playFactions: false,
).execute(two.game, two.human);

List<BaseAssaultEntry> assaults(TwoPlayerGame two) =>
    two.human.historyEntries.whereType<BaseAssaultEntry>().toList();

void main() {
  test('the attack is fought at the end of the turn it was announced for', () {
    final two = announceGame();
    station(two.human, {});
    announce().execute(two.game, two.rival);

    endTurn(two);
    endTurn(two);
    expect(assaults(two), isEmpty);
    expect(pendingOf(two), hasLength(1));

    endTurn(two);
    expect(assaults(two), hasLength(1));
    expect(pendingOf(two), isEmpty);
    expect(two.game.turn, 15);
  });

  test('the units standing on the human base at that time defend', () {
    final two = announceGame();
    station(two.human, {});
    announce().execute(two.game, two.rival);
    endTurn(two);
    endTurn(two);
    station(two.human, wall);

    endTurn(two);

    final entry = assaults(two).single;
    expect(entry.defending, isTrue);
    expect(entry.victory, isFalse);
    expect(entry.units, wall);
  });

  test('a won attack razes the base and pillages it like any attack', () {
    final two = announceGame();
    station(two.human, {});
    announce().execute(two.game, two.rival);
    final hq = two.human.buildings[BuildingType.headquarters]!.level;

    endTurn(two);
    endTurn(two);
    endTurn(two);

    final entry = assaults(two).single;
    expect(entry.victory, isTrue);
    expect(entry.headquartersAfter, lessThan(hq));
    expect(two.human.buildings[BuildingType.headquarters]!.level, hq - 1);
  });

  test('the attacker keeps a history entry and its survivors', () {
    final two = announceGame();
    station(two.human, {});
    announce().execute(two.game, two.rival);

    endTurn(two);
    endTurn(two);
    endTurn(two);

    final mine = two.rival.historyEntries.whereType<BaseAssaultEntry>();
    expect(mine.single.defending, isFalse);
    expect(standing(two.rival, UnitType.harpoonist), inInclusiveRange(1, 40));
  });

  test('a lost attack costs the army and spares the base', () {
    final two = announceGame();
    station(two.human, {});
    announce().execute(two.game, two.rival);
    final hq = two.human.buildings[BuildingType.headquarters]!.level;

    endTurn(two);
    endTurn(two);
    station(two.human, wall);
    endTurn(two);

    expect(two.human.buildings[BuildingType.headquarters]!.level, hq);
    expect(standing(two.rival, UnitType.harpoonist), lessThan(40));
  });

  test('a fallen attacker cancels the attack', () {
    final two = announceGame();
    announce().execute(two.game, two.rival);
    two.rival.savedFallen = true;

    endTurn(two);
    endTurn(two);
    endTurn(two);

    expect(assaults(two), isEmpty);
    expect(pendingOf(two), isEmpty);
  });

  test('the attack goes with the units the attacker still has', () {
    final two = announceGame();
    station(two.human, {});
    announce().execute(two.game, two.rival);

    endTurn(two);
    endTurn(two);
    station(two.rival, {UnitType.harpoonist: 10});
    endTurn(two);

    final mine = two.rival.historyEntries.whereType<BaseAssaultEntry>();
    expect(mine.single.units, {UnitType.harpoonist: 10});
  });

  test('an attacker with nothing left cancels the attack', () {
    final two = announceGame();
    announce().execute(two.game, two.rival);

    endTurn(two);
    endTurn(two);
    station(two.rival, {});
    endTurn(two);

    expect(assaults(two), isEmpty);
    expect(pendingOf(two), isEmpty);
  });
}

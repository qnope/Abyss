import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/domain/leviathan/leviathan_resolver.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import 'leviathan_scene.dart';

void main() {
  test('strikes only once', () {
    final war = leviathanScene();
    war.playUntil(war.strikeTurn + 1);
    for (var i = 0; i < 6; i++) {
      final outcome = war.endTurn();
      expect(outcome.report, isNull);
      expect(outcome.announced, isNull);
    }
    expect(
      war.human.historyEntries.whereType<BaseAssaultEntry>(),
      hasLength(1),
    );
  });

  test('cancelled when a faction took the Faille before the warning', () {
    final war = leviathanScene();
    war.playUntil(war.strikeTurn - 1);
    war.post.capturedBy = war.attacker.id;
    expect(war.endTurn().announced, isNull);
    expect(war.endTurn().report, isNull);
    expect(war.leviathan.isScheduled, isFalse);
    expect(war.post.capturedBy, war.attacker.id);
  });

  test('cancelled when a faction took the Faille during the turn', () {
    final war = leviathanScene();
    war.playUntil(war.strikeTurn);
    war.post.capturedBy = war.attacker.id;
    expect(LeviathanResolver.announcedNow(war.game), isNull);
    expect(war.endTurn().report, isNull);
    expect(war.leviathan.isScheduled, isFalse);
    expect(war.post.capturedBy, war.attacker.id);
  });

  test('the same dice give the same fight', () {
    List<Object> play() {
      final war = leviathanScene();
      war.put(war.human, 2, const {UnitType.harpoonist: 8});
      war.playUntil(war.strikeTurn);
      final report = war.endTurn(seed: 11).report!;
      return [
        report.entry.victory,
        report.entry.fightResult.turnCount,
        report.entry.dead.toString(),
        report.entry.wounded.toString(),
      ];
    }

    expect(play(), play());
  });
}

import 'package:abyss/domain/action/action_failure.dart';
import 'package:abyss/domain/game/difficulty.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/announce_attack_helper.dart';
import '../../../helpers/history_entry_samples.dart';

void main() {
  test('the harder the game, the closer the attacks can come', () {
    expect(Difficulty.easy.attackGap, greaterThan(Difficulty.normal.attackGap));
    expect(Difficulty.normal.attackGap, greaterThan(Difficulty.hard.attackGap));
  });

  test('a second faction waits while an attack is pending', () {
    final two = announceGame();
    announce(army: {UnitType.harpoonist: 10}).execute(two.game, two.rival);

    final other = announceGame(turn: 13, rivalId: 'rival-2');
    other.human.raidState.attacks.addAll(two.human.raidState.attacks);

    expect(
      announce().validate(other.game, other.rival).reason,
      ActionFailure.attackTooSoon,
    );
  });

  test('the gap runs from the last attack fought on the base', () {
    final gap = Difficulty.normal.attackGap;
    final early = announceGame(turn: 14 + gap - 1);
    early.human.addHistoryEntry(
      baseAssaultEntry(victory: true, defending: true),
    );
    final late = announceGame(turn: 14 + gap);
    late.human.addHistoryEntry(
      baseAssaultEntry(victory: true, defending: true),
    );

    expect(
      announce().validate(early.game, early.rival).reason,
      ActionFailure.attackTooSoon,
    );
    expect(announce().validate(late.game, late.rival).isSuccess, isTrue);
  });

  test('an attack of the human on another player does not count', () {
    final two = announceGame(turn: 15);
    two.human.addHistoryEntry(
      baseAssaultEntry(victory: true, defending: false),
    );

    expect(announce().validate(two.game, two.rival).isSuccess, isTrue);
  });

  test('an attack on a post of the human does not count either', () {
    final two = announceGame(turn: 15);
    two.human.addHistoryEntry(
      baseAssaultEntry(victory: true, defending: true, post: 'Faille Beta'),
    );

    expect(announce().validate(two.game, two.rival).isSuccess, isTrue);
  });
}

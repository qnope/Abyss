import 'package:abyss/domain/faction/faction_personality.dart';
import 'package:abyss/domain/faction/faction_traits.dart';
import 'package:abyss/domain/faction/faction_war.dart';
import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/base_attack_helper.dart';
import '../../helpers/faction_war_helper.dart';

/// A war where the human is stronger than the rival, but still beatable.
War _war({required bool grudge}) {
  final war = warGame();
  final FactionPersonality p = war.game.factions[0].personality;
  while (!FactionWar.isDue(war.game.turn, p) ||
      FactionWar.isGrudgeSlot(war.game.turn, p) != grudge) {
    war.game.turn++;
  }
  war.see(war.human);
  war.see(war.rival);
  station(war.human, {UnitType.harpoonist: 6});
  return war;
}

void main() {
  test('a grudge slot comes every few slots, never off a slot', () {
    for (final p in FactionPersonality.values) {
      final every = FactionTraits.of(p).grudgeEvery;
      final slots = [
        for (var t = 1; t <= 120; t++)
          if (FactionWar.isDue(t, p)) t,
      ];
      final grudges = slots.where((t) => FactionWar.isGrudgeSlot(t, p));
      expect(grudges, isNotEmpty, reason: p.name);
      expect(
        slots.length ~/ grudges.length,
        inInclusiveRange(every - 1, every + 1),
      );
      for (var t = 1; t <= 120; t++) {
        if (!FactionWar.isDue(t, p)) {
          expect(FactionWar.isGrudgeSlot(t, p), isFalse);
        }
      }
    }
  });

  test('the Pillagers and the Horde hold the grudge sooner than the rest', () {
    final base = FactionTraits.of(FactionPersonality.pearlOrder).grudgeEvery;
    expect(base, 3);
    for (final p in [
      FactionPersonality.wreckPillagers,
      FactionPersonality.murenaHorde,
    ]) {
      expect(FactionTraits.of(p).grudgeEvery, 2);
    }
  });

  test('on a grudge slot it hits the human it can beat, not the weakest', () {
    final war = _war(grudge: true);

    war.play();

    expect(war.human.raidState.attacks, hasLength(1));
    expect(war.rival.historyEntries.whereType<BaseAssaultEntry>(), isEmpty);
  });

  test('on another slot it still hits the weakest base', () {
    final war = _war(grudge: false);

    war.play();

    expect(war.human.raidState.attacks, isEmpty);
    expect(
      war.rival.historyEntries.whereType<BaseAssaultEntry>(),
      hasLength(1),
    );
  });

  test('a grudge never sends an army that loses: it falls back', () {
    final war = _war(grudge: true);
    station(war.human, wall);

    war.play();

    expect(war.human.raidState.attacks, isEmpty);
    expect(
      war.rival.historyEntries.whereType<BaseAssaultEntry>(),
      hasLength(1),
    );
  });

  test('a grudge needs a base the fog showed', () {
    final fresh = warGame();
    while (!FactionWar.isGrudgeSlot(
      fresh.game.turn,
      fresh.game.factions[0].personality,
    )) {
      fresh.game.turn++;
    }
    fresh.see(fresh.rival);
    station(fresh.human, {UnitType.harpoonist: 6});

    fresh.play();

    expect(fresh.human.raidState.attacks, isEmpty);
  });
}

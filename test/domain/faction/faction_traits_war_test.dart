import 'package:abyss/domain/faction/faction_personality.dart';
import 'package:abyss/domain/faction/faction_traits.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  FactionTraits of(FactionPersonality p) => FactionTraits.of(p);

  test('war comes about a quarter sooner, never under three turns', () {
    const cadences = <FactionPersonality, int>{
      FactionPersonality.wreckPillagers: 4,
      FactionPersonality.pearlOrder: 7,
      FactionPersonality.anglerCult: 4,
      FactionPersonality.murenaHorde: 3,
      FactionPersonality.siphonophoreGuild: 9,
      FactionPersonality.silenceMonks: 9,
      FactionPersonality.currentNomads: 5,
      FactionPersonality.pyrosomeHive: 6,
      FactionPersonality.magmaSmiths: 6,
      FactionPersonality.krakenFaithful: 4,
    };
    for (final p in FactionPersonality.values) {
      expect(of(p).cadence, cadences[p], reason: p.name);
      expect(of(p).cadence, greaterThanOrEqualTo(3), reason: p.name);
    }
    expect(const FactionTraits().cadence, 5);
  });

  test('the timid attack once they win seven rehearsals of eight', () {
    for (final p in <FactionPersonality>[
      FactionPersonality.pearlOrder,
      FactionPersonality.silenceMonks,
      FactionPersonality.siphonophoreGuild,
    ]) {
      final planner = of(p).planner;
      expect(planner.rehearsals, 8, reason: p.name);
      expect(7 / 8, greaterThanOrEqualTo(planner.confidence), reason: p.name);
      expect(6 / 8, lessThan(planner.confidence), reason: p.name);
    }
  });
}

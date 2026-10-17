import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/faction/faction_personality.dart';
import 'package:abyss/domain/faction/faction_traits.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  _otherSeven();
  FactionTraits of(FactionPersonality p) => FactionTraits.of(p);

  test('every personality has traits', () {
    for (final p in FactionPersonality.values) {
      expect(of(p).cadence, greaterThan(0));
      expect(of(p).confidence, inInclusiveRange(0.5, 1));
    }
  });

  test('the Pillagers strike often, boldly, with harpoonists', () {
    final pillagers = of(FactionPersonality.wreckPillagers);
    final order = of(FactionPersonality.pearlOrder);
    expect(pillagers.cadence, lessThan(order.cadence));
    expect(pillagers.confidence, lessThan(order.confidence));
    expect(pillagers.warMix.keys, contains(UnitType.harpoonist));
  });

  test('the Order builds its economy first and arms with guardians', () {
    final order = of(FactionPersonality.pearlOrder);
    expect(order.warMix.keys, contains(UnitType.guardian));
    expect(order.growth.last, BuildingType.barracks);
    expect(
      order.cadence,
      greaterThan(of(FactionPersonality.anglerCult).cadence),
    );
  });

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

  test('the Cult goes for the posts first', () {
    expect(of(FactionPersonality.anglerCult).postsFirst, isTrue);
    expect(of(FactionPersonality.pearlOrder).postsFirst, isFalse);
  });
}

void _otherSeven() {
  FactionTraits of(FactionPersonality p) => FactionTraits.of(p);

  group('the other seven', () {
    test('every personality plays its own way', () {
      final seen = <String>{};
      for (final p in FactionPersonality.values) {
        final t = of(p);
        expect(
          seen.add(
            '${t.cadence}/${t.confidence}/${t.warMix}/${t.warShare}/'
            '${t.conquestShare}/${t.postsFirst}/${t.kernelFirst}/'
            '${t.guardShare}/${t.explorers}/${t.rushUntil}/${t.growth}',
          ),
          isTrue,
          reason: '${p.name} plays like another',
        );
      }
    });

    test('the Horde rushes before turn 30 with harpoonists', () {
      final horde = of(FactionPersonality.murenaHorde);
      expect(horde.warMix.keys, [UnitType.harpoonist]);
      expect(horde.rushUntil, 30);
      expect(horde.shareOn(10), greaterThan(horde.shareOn(40)));
    });

    test('the Guild waits, builds the rampart early and strikes surely', () {
      final guild = of(FactionPersonality.siphonophoreGuild);
      expect(
        guild.confidence,
        greaterThan(of(FactionPersonality.wreckPillagers).confidence),
      );
      expect(
        guild.growth.indexOf(BuildingType.coralCitadel),
        lessThan(
          of(
            FactionPersonality.murenaHorde,
          ).growth.indexOf(BuildingType.coralCitadel),
        ),
      );
    });

    test('the Nomads explore more and raise the Citadel last', () {
      final nomads = of(FactionPersonality.currentNomads);
      expect(nomads.explorers, greaterThan(2));
      expect(nomads.growth.last, BuildingType.coralCitadel);
    });

    test('the Hive grows its farms and barracks first', () {
      final hive = of(FactionPersonality.pyrosomeHive);
      expect(hive.growth.take(2), [
        BuildingType.algaeFarm,
        BuildingType.barracks,
      ]);
    });

    test('the Smiths race harder and take the posts of the others', () {
      final smiths = of(FactionPersonality.magmaSmiths);
      expect(smiths.conquestShare, greaterThan(0.5));
      expect(smiths.postsFirst, isTrue);
    });

    test('the Faithful lay siege to the kernel first and garrison it', () {
      final faithful = of(FactionPersonality.krakenFaithful);
      expect(faithful.kernelFirst, isTrue);
      expect(faithful.guardShare, greaterThan(0.5));
    });

    test('the Monks strike rarely with saboteurs', () {
      final monks = of(FactionPersonality.silenceMonks);
      expect(monks.warMix.keys, contains(UnitType.saboteur));
      for (final p in FactionPersonality.values) {
        expect(monks.cadence, greaterThanOrEqualTo(of(p).cadence));
      }
    });
  });
}

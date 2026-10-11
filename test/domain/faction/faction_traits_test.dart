import 'package:abyss/domain/faction/faction_personality.dart';
import 'package:abyss/domain/faction/faction_traits.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
    expect(pillagers.defends, isFalse);
  });

  test('the Order builds its economy first and arms with guardians', () {
    final order = of(FactionPersonality.pearlOrder);
    expect(order.warMix.keys, contains(UnitType.guardian));
    expect(
      order.warShare,
      lessThan(of(FactionPersonality.wreckPillagers).warShare),
    );
  });

  test('the Cult goes for the posts first', () {
    expect(of(FactionPersonality.anglerCult).postsFirst, isTrue);
    expect(of(FactionPersonality.pearlOrder).postsFirst, isFalse);
  });
}

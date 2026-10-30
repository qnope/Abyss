import 'package:abyss/presentation/widgets/base/base_pad_tier.dart';
import 'package:abyss/presentation/widgets/map/map_projection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the plot grows with the level of its building', () {
    final tiers = {
      for (final level in [0, 1, 3, 4, 7, 8, 10])
        level: BasePadTier.ofLevel(level),
    };
    expect(tiers, {
      0: BasePadTier.plot,
      1: BasePadTier.gravel,
      3: BasePadTier.gravel,
      4: BasePadTier.deck,
      7: BasePadTier.deck,
      8: BasePadTier.litDeck,
      10: BasePadTier.litDeck,
    });
  });

  test('a level past the last tier keeps the lit deck', () {
    expect(BasePadTier.ofLevel(12), BasePadTier.litDeck);
  });

  test('a surveyed plot lies on the ground, a slab thickens per tier', () {
    expect(BasePadTier.plot.lift, 0);
    const unit = MapProjection.tileWidth / 48;
    expect(BasePadTier.gravel.lift, closeTo(4 * unit, 1e-9));
    expect(BasePadTier.deck.lift, closeTo(5.5 * unit, 1e-9));
    expect(BasePadTier.litDeck.lift, closeTo(7 * unit, 1e-9));
  });
}

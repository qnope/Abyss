import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/presentation/widgets/base/base_badge.dart';
import 'package:abyss/presentation/widgets/base/base_pad_tier.dart';
import 'package:abyss/presentation/widgets/base/base_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const hq = BuildingType.headquarters, farm = BuildingType.algaeFarm;

  Player player({int hqLevel = 2, int farmLevel = 1}) =>
      Player(name: 'Nemo')
        ..buildings[hq]!.level = hqLevel
        ..buildings[farm]!.level = farmLevel;

  test('reads the level and the pad of every building', () {
    final base = BaseSnapshot.of(player(farmLevel: 5).buildings);
    expect(base.levels[hq], 2);
    expect(base.levels[farm], 5);
    expect(base.tiers[hq], BasePadTier.gravel);
    expect(base.tiers[farm], BasePadTier.deck);
    expect(base.tiers[BuildingType.barracks], BasePadTier.plot);
  });

  test('a level raised within its tier keeps the same pads', () {
    final before = BaseSnapshot.of(player(farmLevel: 1).buildings);
    final after = BaseSnapshot.of(player(farmLevel: 3).buildings);
    expect(after.tiers, before.tiers);
    expect(after.levels, isNot(before.levels));
  });

  test('a building above what its headquarters allows is degraded', () {
    expect(BaseSnapshot.of(player(farmLevel: 3).buildings).degraded, {farm});
    expect(BaseSnapshot.of(player(farmLevel: 2).buildings).degraded, isEmpty);
  });

  group('the marks over the buildings', () {
    const barracks = BuildingType.barracks, lab = BuildingType.laboratory;

    test('only a built building that may rise shows a chevron', () {
      final base = BaseSnapshot.of(
        player().buildings,
        upgradable: {hq, farm, barracks},
      );
      expect(base.upgradable, {hq, farm});
      expect(base.badgeOf(hq), BaseBadge.upgrade);
      expect(base.badgeOf(barracks), isNull);
    });

    test('a degraded building shows its triangle, never a chevron', () {
      final base = BaseSnapshot.of(
        player(farmLevel: 3).buildings,
        upgradable: {farm},
      );
      expect(base.upgradable, isEmpty);
      expect(base.badgeOf(farm), BaseBadge.warning);
    });

    test('a building with nothing to say shows no badge', () {
      expect(BaseSnapshot.of(player().buildings).badgeOf(farm), isNull);
    });

    test('only a plot can be locked', () {
      final base = BaseSnapshot.of(player().buildings, locked: {farm, lab});
      expect(base.locked, {lab});
    });
  });
}

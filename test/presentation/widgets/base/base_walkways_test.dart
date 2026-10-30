import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/presentation/widgets/base/base_layout.dart';
import 'package:abyss/presentation/widgets/base/base_slot.dart';
import 'package:abyss/presentation/widgets/base/base_walkways.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const layout = BaseLayout.island;
  const hq = BuildingType.headquarters;
  final hqCentre = layout.slotOf(hq).centre;

  List<BaseWalkway> walkways(Set<BuildingType> built) =>
      baseWalkways(layout, built);

  test('no walkway before the headquarters is built', () {
    expect(walkways({BuildingType.algaeFarm, BuildingType.coralMine}), isEmpty);
  });

  test('no walkway to the headquarters alone, nor to unbuilt buildings', () {
    expect(walkways({hq}), isEmpty);
  });

  test('a built building is reached by an L along the grid axes', () {
    final legs = walkways({hq, BuildingType.algaeFarm});
    expect(legs, hasLength(2));
    expect(legs.first.$1, hqCentre);
    expect(legs.last.$2, layout.slotOf(BuildingType.algaeFarm).centre);
    expect(legs.first.$2, legs.last.$1);
    for (final (from, to) in legs) {
      expect(from.dx == to.dx || from.dy == to.dy, isTrue);
    }
  });

  test('the first leg runs along the longer side, as on the mockup', () {
    final (from, to) = walkways({hq, BuildingType.oreExtractor}).first;
    expect(to.dy, from.dy);
    expect(to.dx, layout.slotOf(BuildingType.oreExtractor).u);
  });

  test('every built building gets its own walkway', () {
    final built = BuildingType.values.toSet();
    final legs = walkways(built);
    expect(legs, hasLength(2 * (built.length - 1)));
    final ends = {for (final leg in legs) leg.$2};
    for (final type in built.difference({hq})) {
      expect(ends, contains(layout.slotOf(type).centre), reason: '$type');
    }
  });

  test('a building in line with the headquarters gets a single leg', () {
    const line = BaseLayout(size: 6, slots: {
      hq: BaseSlot(u: 3, v: 3, footprint: 2, scale: 1),
      BuildingType.algaeFarm: BaseSlot(u: 3, v: 0.5, footprint: 1, scale: 1),
    });
    expect(baseWalkways(line, {hq, BuildingType.algaeFarm}), [
      (const Offset(3, 3), const Offset(3, 0.5)),
    ]);
  });

  test('a walkway never has a leg of no length', () {
    for (final type in BuildingType.values) {
      for (final (from, to) in walkways({hq, type})) {
        expect((to - from).distance, greaterThan(0), reason: '$type');
      }
    }
  });
}

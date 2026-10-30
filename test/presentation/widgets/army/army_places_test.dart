import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/domain/volcano/kernel_garrison.dart';
import 'package:abyss/presentation/widgets/army/army_places.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const scout = UnitType.scout, harpoonist = UnitType.harpoonist;
  const kernel = KernelGarrison.stockKey;
  const places = ArmyPlaces({
    1: {scout: 10, harpoonist: 0},
    2: {scout: 4, harpoonist: 2},
    3: {harpoonist: 0},
    kernel: {harpoonist: 5},
  });

  test('holds the places with at least one unit, levels then kernel', () {
    expect(places.held, [1, 2, kernel]);
  });

  test('counts the units of each place, every place for all', () {
    expect(places.countsAt(2), {scout: 4, harpoonist: 2});
    expect(places.countsAt(kernel), {harpoonist: 5});
    expect(places.countsAt(3), isEmpty);
    expect(places.countsAt(ArmyPlaces.all), {scout: 14, harpoonist: 7});
  });

  test('counts a type at a place, none where it does not serve', () {
    expect(places.countOf(harpoonist, 2), 2);
    expect(places.countOf(scout, kernel), 0);
    expect(places.countOf(harpoonist, ArmyPlaces.all), 7);
  });

  test('totals the units of a place and of the whole army', () {
    expect(places.totalAt(1), 10);
    expect(places.totalAt(kernel), 5);
    expect(places.totalAt(ArmyPlaces.all), 21);
  });

  test('is split once two places hold units', () {
    expect(places.isSplit, isTrue);
    expect(
      const ArmyPlaces({
        1: {scout: 3},
        2: {scout: 0},
      }).isSplit,
      isFalse,
    );
    expect(const ArmyPlaces().isSplit, isFalse);
  });

  test('two armies alike are equal', () {
    expect(
      const ArmyPlaces({
        1: {scout: 3},
      }),
      const ArmyPlaces({
        1: {scout: 3},
      }),
    );
    expect(
      const ArmyPlaces({
        1: {scout: 3},
      }).hashCode,
      const ArmyPlaces({
        1: {scout: 3},
      }).hashCode,
    );
    expect(
      const ArmyPlaces({
        1: {scout: 3},
      }),
      isNot(
        const ArmyPlaces({
          2: {scout: 3},
        }),
      ),
    );
  });
}

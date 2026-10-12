import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/objective/guide/guide_area.dart';
import 'package:abyss/domain/objective/guide/guide_target.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final cell = GridPosition(x: 3, y: 4);

  test('a cell target surrounds one cell of one level of the map', () {
    final target = GuideTarget.cell(2, cell);
    expect(target.area, GuideArea.map);
    expect(target.level, 2);
    expect(target.isCell(2, 3, 4), isTrue);
    expect(target.isCell(1, 3, 4), isFalse);
    expect(target.isCell(2, 4, 3), isFalse);
    expect(target.garrison, isFalse);
    expect(target.isBuilding(BuildingType.barracks), isFalse);
  });

  test('the map alone surrounds no cell', () {
    const target = GuideTarget.map();
    expect(target.level, isNull);
    expect(target.isCell(1, 3, 4), isFalse);
  });

  test('a garrison target surrounds the kernel and its garrison button', () {
    final target = GuideTarget.garrison(3, cell);
    expect(target.area, GuideArea.map);
    expect(target.isCell(3, 3, 4), isTrue);
    expect(target.garrison, isTrue);
  });

  test('cell targets compare by level, cell and garrison', () {
    expect(
      GuideTarget.cell(2, cell),
      GuideTarget.cell(2, GridPosition(x: 3, y: 4)),
    );
    expect(
      GuideTarget.cell(2, cell).hashCode,
      GuideTarget.cell(2, GridPosition(x: 3, y: 4)).hashCode,
    );
    expect(GuideTarget.cell(2, cell), isNot(GuideTarget.cell(1, cell)));
    expect(GuideTarget.cell(3, cell), isNot(GuideTarget.garrison(3, cell)));
    expect(GuideTarget.cell(2, cell), isNot(const GuideTarget.map()));
    expect(GuideTarget.cell(2, cell).toString(), contains('2'));
  });
}

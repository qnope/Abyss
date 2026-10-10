import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/objective/guide/guide_area.dart';
import 'package:abyss/domain/objective/guide/guide_target.dart';
import 'package:abyss/domain/tech/tech_branch.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('each target lies in the area of the screen to open', () {
    expect(
      const GuideTarget.building(BuildingType.barracks).area,
      GuideArea.base,
    );
    expect(const GuideTarget.map().area, GuideArea.map);
    expect(const GuideTarget.unit(UnitType.scout).area, GuideArea.army);
    expect(
      const GuideTarget.unlock({TechBranch.military}).area,
      GuideArea.research,
    );
    expect(
      const GuideTarget.research({TechBranch.military}).area,
      GuideArea.research,
    );
    expect(const GuideTarget.endTurn().area, isNull);
  });

  test('a building target surrounds its card only', () {
    const target = GuideTarget.building(BuildingType.barracks);
    expect(target.isBuilding(BuildingType.barracks), isTrue);
    expect(target.isBuilding(BuildingType.laboratory), isFalse);
    expect(target.isUnit(UnitType.scout), isFalse);
    expect(target.endTurn, isFalse);
  });

  test('a unit target surrounds its card only', () {
    const target = GuideTarget.unit(UnitType.scout);
    expect(target.isUnit(UnitType.scout), isTrue);
    expect(target.isUnit(UnitType.harpoonist), isFalse);
    expect(target.isBuilding(BuildingType.barracks), isFalse);
  });

  test('an unlock target surrounds the medallions of its branches', () {
    const target = GuideTarget.unlock({TechBranch.military});
    expect(target.isBranch(TechBranch.military), isTrue);
    expect(target.isBranch(TechBranch.explorer), isFalse);
    expect(target.isTechNode(TechBranch.military, 1), isFalse);
  });

  test('a research target surrounds the first node of its branches', () {
    const target = GuideTarget.research({TechBranch.explorer});
    expect(target.isTechNode(TechBranch.explorer, 1), isTrue);
    expect(target.isTechNode(TechBranch.explorer, 2), isFalse);
    expect(target.isTechNode(TechBranch.military, 1), isFalse);
    expect(target.isBranch(TechBranch.explorer), isFalse);
  });

  test('the end of the turn surrounds the next turn button', () {
    expect(const GuideTarget.endTurn().endTurn, isTrue);
  });

  test('targets compare by value, whatever the order of the branches', () {
    expect(
      GuideTarget.unlock({TechBranch.military, TechBranch.explorer}),
      GuideTarget.unlock({TechBranch.explorer, TechBranch.military}),
    );
    expect(
      GuideTarget.unlock({TechBranch.military, TechBranch.explorer}).hashCode,
      GuideTarget.unlock({TechBranch.explorer, TechBranch.military}).hashCode,
    );
    expect(
      const GuideTarget.unlock({TechBranch.military}),
      isNot(const GuideTarget.research({TechBranch.military})),
    );
    expect(
      const GuideTarget.building(BuildingType.barracks),
      isNot(const GuideTarget.building(BuildingType.laboratory)),
    );
  });
}

import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/presentation/widgets/base/base_hit.dart';
import 'package:abyss/presentation/widgets/base/base_layout.dart';
import 'package:abyss/presentation/widgets/base/base_slot_projection.dart';
import 'package:abyss/presentation/widgets/map/map_standing_hit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const layout = BaseLayout.island;

  BuildingType? at(Offset point) => baseBuildingAt(point, layout);

  bool underSomeSprite(Offset point) => layout.slots.values
      .any((slot) => standingHitBox(slot.standingBox).contains(point));

  test('touching the middle of a lone building picks it', () {
    final slot = layout.slotOf(BuildingType.solarPanel);
    expect(at(slot.standingBox.center), BuildingType.solarPanel);
  });

  test('where two buildings overlap, the front one wins', () {
    final point = layout.slotOf(BuildingType.coralMine).foot;
    final mine = layout.slotOf(BuildingType.coralMine).standingBox;
    final capsule = layout.slotOf(BuildingType.pressureCapsule).standingBox;
    expect(standingHitBox(mine).contains(point), isTrue);
    expect(standingHitBox(capsule).contains(point), isTrue);
    expect(at(point), BuildingType.pressureCapsule);
  });

  test('off every sprite, the footprint under the finger picks', () {
    final hq = layout.slotOf(BuildingType.headquarters);
    final point = Offset(hq.foot.dx - 40, hq.standingBox.bottom + 1);
    expect(underSomeSprite(point), isFalse);
    expect(hq.footprintDiamond.contains(point), isTrue);
    expect(at(point), BuildingType.headquarters);
  });

  test('empty ground picks nothing', () {
    final corner = baseGroundToProjection(const Offset(0.5, 11.5));
    expect(underSomeSprite(corner), isFalse);
    expect(at(corner), isNull);
  });
}

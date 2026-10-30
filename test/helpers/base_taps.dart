import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/presentation/widgets/base/base_fit.dart';
import 'package:abyss/presentation/widgets/base/base_hit.dart';
import 'package:abyss/presentation/widgets/base/base_slot_projection.dart';
import 'package:abyss/presentation/widgets/base/base_view.dart';
import 'package:abyss/presentation/widgets/map/map_standing_hit.dart';
import 'package:flutter_test/flutter_test.dart';

/// A point of the screen where touching the shown base picks [type]:
/// on its sprite, or on its footprint where no sprite stands in front.
Offset buildingSpot(WidgetTester tester, BuildingType type) {
  final view = tester.getRect(find.byType(BaseView));
  final layout = tester.widget<BaseView>(find.byType(BaseView)).layout;
  final fit = BaseFit.of(view.size, layout);
  final slot = layout.slotOf(type);
  for (final box in [standingHitBox(slot.standingBox), slot.footprintBox]) {
    final points = [
      for (var i = 1; i < 10; i++)
        for (var j = 1; j < 10; j++)
          Offset(box.left + box.width * i / 10, box.top + box.height * j / 10),
    ]..sort((a, b) => (a - box.center).distance
        .compareTo((b - box.center).distance));
    for (final point in points) {
      final onScreen = view.topLeft + fit.toView(point);
      if (baseBuildingAt(point, layout) == type &&
          view.deflate(1).contains(onScreen)) {
        return onScreen;
      }
    }
  }
  throw StateError('$type cannot be touched on the base');
}

/// Touches [type] on the shown base, as a player would.
Future<void> tapBuilding(WidgetTester tester, BuildingType type) =>
    tester.tapAt(buildingSpot(tester, type));


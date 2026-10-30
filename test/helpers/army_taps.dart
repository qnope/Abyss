import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/widgets/army/army_fit.dart';
import 'package:abyss/presentation/widgets/army/army_layout.dart';
import 'package:abyss/presentation/widgets/army/army_slots.dart';
import 'package:abyss/presentation/widgets/army/army_view.dart';
import 'package:abyss/presentation/widgets/base/base_pad_geometry.dart';
import 'package:abyss/presentation/widgets/base/base_pad_tier.dart';
import 'package:abyss/presentation/widgets/base/base_slot_projection.dart';
import 'package:flutter_test/flutter_test.dart';

/// The point of the screen over the projection [point] of the shown
/// parade ground.
Offset armyPoint(WidgetTester tester, Offset point) {
  final view = tester.getRect(find.byType(ArmyView));
  return view.topLeft + ArmyFit.of(view.size).toView(point);
}

/// The point of the screen over the ground [cell] of the shown parade
/// ground.
Offset armySpot(WidgetTester tester, Offset cell) =>
    armyPoint(tester, baseGroundToProjection(cell));

/// Touches the middle of the drill pad of [type], as a player would.
Future<void> tapDrillPad(WidgetTester tester, UnitType type) =>
    tester.tapAt(armySpot(tester, ArmyLayout.padCentre(type)));

/// Touches the middle of the barracks standing at [level].
Future<void> tapBarracks(WidgetTester tester, int level) => tester.tapAt(
    armyPoint(tester,
        ArmySlots.barracks.standingBoxOn(BasePadTier.ofLevel(level)).center));

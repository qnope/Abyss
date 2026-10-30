import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/widgets/army/army_fit.dart';
import 'package:abyss/presentation/widgets/army/army_layout.dart';
import 'package:abyss/presentation/widgets/army/army_view.dart';
import 'package:abyss/presentation/widgets/base/base_slot_projection.dart';
import 'package:flutter_test/flutter_test.dart';

/// The point of the screen over the ground [cell] of the shown parade
/// ground.
Offset armySpot(WidgetTester tester, Offset cell) {
  final view = tester.getRect(find.byType(ArmyView));
  final fit = ArmyFit.of(view.size);
  return view.topLeft + fit.toView(baseGroundToProjection(cell));
}

/// Touches the middle of the drill pad of [type], as a player would.
Future<void> tapDrillPad(WidgetTester tester, UnitType type) =>
    tester.tapAt(armySpot(tester, ArmyLayout.padCentre(type)));

import 'dart:ui';

import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/presentation/widgets/base/base_cable.dart';
import 'package:abyss/presentation/widgets/base/base_layout.dart';
import 'package:abyss/presentation/widgets/base/base_slot_projection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const layout = BaseLayout.island;
  const descent = BuildingType.descentModule;

  test('no cable while the Descent module is not built', () {
    expect(BaseCable.of(layout, const {}), isNull);
    expect(BaseCable.of(layout, {BuildingType.headquarters}), isNull);
  });

  test('a cable hangs from the lip of the plateau near the module', () {
    final cable = BaseCable.of(layout, {descent})!;
    final lip = baseProjectionToGround(cable.top);
    final slot = layout.slotOf(descent);
    expect(lip.dx, closeTo(layout.size.toDouble(), 1e-9));
    expect((lip.dy - slot.v).abs(), lessThan(slot.footprint.toDouble()));
  });

  test('its cabin hangs down the cable, between its top and the bottom', () {
    final cable = BaseCable.of(layout, {descent})!;
    final bottom = cable.top.dy + 1000;
    final cabin = cable.cabinAt(bottom);
    expect(cabin.dy, greaterThan(cable.top.dy));
    expect(cabin.dy, lessThan(bottom));
  });

  test('paints, with a cabin even on a short drop', () {
    final cable = BaseCable.of(layout, {descent})!;
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    cable.paint(canvas, bottom: cable.top.dy + 600);
    cable.paint(canvas, bottom: cable.top.dy - 10);
    recorder.endRecording().dispose();
  });

  test('a plateau without a Descent module has no cable', () {
    const parade = BaseLayout(size: 9, slots: {});
    expect(BaseCable.of(parade, {descent}), isNull);
  });
}

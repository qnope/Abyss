import 'dart:ui';

import 'package:abyss/presentation/theme/abyss_colors.dart';
import 'package:abyss/presentation/widgets/army/army_plaque_arrival_drawer.dart';
import 'package:abyss/presentation/widgets/army/squad_arrival.dart';
import 'package:abyss/presentation/widgets/base/base_pad_tier.dart';
import 'package:flutter_test/flutter_test.dart';

import 'army_plaque_arrival_fixtures.dart';

void main() {
  const size = Size(120, 60);

  /// The most opaque pixel of the gain floating at [t] for a squad that
  /// grew by [gained], and how many columns it covers; the plaque and its
  /// glow are drawn out of the picture, left of it.
  Future<(Color, int)> floatingAt(double t, {int gained = 5}) async {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder)
      ..translate(10 - LoggedPlaques.right - 2 * basePadUnit, size.height);
    ArmyPlaqueArrivalDrawer(LoggedPlaques([])).paint(
      canvas,
      Offset.zero,
      before: before,
      after: after,
      arrival: SquadArrival(figure: 0, stays: true, gained: gained),
      t: t,
      zoom: 1,
    );
    final image = recorder.endRecording().toImageSync(
      size.width.toInt(),
      size.height.toInt(),
    );
    final bytes =
        (await image.toByteData(format: ImageByteFormat.rawStraightRgba))!;
    image.dispose();
    var (strongest, columns) = (0, <int>{});
    for (var i = 0; i < bytes.lengthInBytes; i += 4) {
      final alpha = bytes.getUint8(i + 3);
      if (alpha > 0) columns.add(i ~/ 4 % size.width.toInt());
      if (alpha > bytes.getUint8(strongest + 3)) strongest = i;
    }
    final [r, g, b, a] = [
      for (var k = 0; k < 4; k++) bytes.getUint8(strongest + k),
    ];
    return (Color.fromARGB(a, r, g, b), columns.length);
  }

  test('the gain floats in green, fading out as it rises', () async {
    final opacities = <double>[];
    for (final t in [.5, .7, .95]) {
      final (colour, _) = await floatingAt(t);
      expect(colour.withValues(alpha: 1), isSameColorAs(AbyssColors.success));
      opacities.add(colour.a);
    }
    final [early, middle, late] = opacities;
    expect(early, greaterThan(.9));
    expect(middle, inExclusiveRange(late, early));
    expect(late, lessThan(.5));
  });

  test('the float reads « +N », as wide as the gain is long', () async {
    final (_, five) = await floatingAt(.6);
    final (_, twelve) = await floatingAt(.6, gained: 12);
    expect(twelve / five, closeTo(3 / 2, .1));
  });
}

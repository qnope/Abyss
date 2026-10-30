import 'dart:typed_data';
import 'dart:ui';

import 'package:abyss/presentation/widgets/ambience/delta_float.dart';
import 'package:abyss/presentation/widgets/army/army_plaque.dart';
import 'package:abyss/presentation/widgets/army/army_plaque_arrival_drawer.dart';
import 'package:abyss/presentation/widgets/army/squad_arrival.dart';
import 'package:abyss/presentation/widgets/base/base_pad_tier.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/spy_canvas.dart';
import 'army_plaque_arrival_fixtures.dart';

void main() {
  const at = Offset(100, 60);

  /// The calls made drawing the plaque at [t], #plaque for each plaque,
  /// each text by the box it is drawn in.
  List<(Symbol, List<dynamic>)> drawn(double t, {double zoom = 1}) {
    final log = <(Symbol, List<dynamic>)>[];
    ArmyPlaqueArrivalDrawer(LoggedPlaques(log)).paint(
      SpyCanvas(
        (method, args) => log.add((
          method,
          switch (args) {
            [final Paragraph text, final Offset corner]
                when method == #drawParagraph =>
              [corner & Size(text.width, text.height)],
            _ => args,
          },
        )),
      ),
      at,
      before: before,
      after: after,
      arrival: arrival,
      t: t,
      zoom: zoom,
    );
    return log;
  }

  List<ArmyPlaque> plaquesAt(double t) => [
    for (final (method, args) in drawn(t))
      if (method == #plaque) args[0] as ArmyPlaque,
  ];

  /// The colours of the glow's discs drawn at [t].
  List<Color> glowAt(double t) => [
    for (final (method, args) in drawn(t))
      if (method == #drawCircle) (args[2] as Paint).color,
  ];

  /// Where the plaque's centre stands at [t], under its pose.
  Offset centreAt(double t) {
    final log = drawn(t);
    final i = log.indexWhere((call) => call.$1 == #plaque);
    if (i == 0 || log[i - 1].$1 != #transform) return log[i].$2[1] as Offset;
    final pose = Matrix4.fromFloat64List(log[i - 1].$2[0] as Float64List);
    return MatrixUtils.transformPoint(pose, log[i].$2[1] as Offset);
  }

  /// The boxes the floating gain is drawn in at [t].
  List<Rect> floatsAt(double t, {double zoom = 1}) => [
    for (final (method, args) in drawn(t, zoom: zoom))
      if (method == #drawParagraph) args[0] as Rect,
  ];

  group('the plaque', () {
    test('shows the old count, still, until the recruit lands', () {
      for (final t in const [0.0, .2, SquadArrival.landing - .01]) {
        expect(plaquesAt(t), [before], reason: 'at $t');
        expect(centreAt(t), at, reason: 'at $t');
        expect(glowAt(t), isEmpty, reason: 'at $t');
      }
    });

    test('pops the new count once landed, glowing in the squad colour', () {
      expect(plaquesAt(.5), [after]);
      final glow = glowAt(.5);
      expect(glow, hasLength(2));
      for (final colour in glow) {
        expect(colour.withValues(alpha: 1), isSameColorAs(after.colour));
      }
    });

    test('rises from below into place as the arrival runs', () {
      final (early, later) = (centreAt(.5), centreAt(.6));
      expect(early.dx, closeTo(at.dx, 1e-9));
      expect(early.dy, greaterThan(later.dy));
      expect(later.dy, greaterThan(at.dy));
    });

    test('stands at rest, without glow, at the end of the arrival', () {
      expect(plaquesAt(1), [after]);
      expect(centreAt(1), at);
      expect(glowAt(1), isEmpty);
    });
  });

  group('the floating gain', () {
    test('floats nothing early in the fall, nor once the arrival ends', () {
      expect(floatsAt(.2), isEmpty);
      expect(floatsAt(1), isEmpty);
    });

    test('floats « +N » right of the new plaque, rising as it runs', () {
      final left = at.dx + LoggedPlaques.right + 2 * basePadUnit;
      for (final t in [.5, .8]) {
        final floats = floatsAt(t);
        expect(floats, hasLength(1), reason: 'at $t');
        final lift = DeltaFloat.liftAt(SquadArrival.floatAt(t));
        expect(floats.single.left, left);
        expect(
          floats.single.center.dy,
          closeTo(at.dy - DeltaFloat.defaultRise * lift, 1e-9),
        );
      }
    });

    test('keeps its size and rise on the screen whatever the zoom', () {
      final (near, far) = (floatsAt(.6).single, floatsAt(.6, zoom: 2).single);
      expect(far.height, closeTo(near.height / 2, 1e-9));
      expect(
        at.dy - far.center.dy,
        closeTo((at.dy - near.center.dy) / 2, 1e-9),
      );
    });
  });
}

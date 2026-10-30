import 'package:abyss/presentation/widgets/guide/guide_halo_painter.dart';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const pulse = AlwaysStoppedAnimation<double>(0.5);

  GuideHaloPainter halo({
    Animation<double> pulse = pulse,
    BoxShape shape = BoxShape.rectangle,
    double radius = 8,
    EdgeInsets inset = EdgeInsets.zero,
    Path Function(Rect box)? outline,
    bool glow = true,
  }) =>
      GuideHaloPainter(
        pulse: pulse,
        shape: shape,
        radius: radius,
        inset: inset,
        outline: outline,
        glow: glow,
      );

  test('a rebuilt halo of the same look is not repainted', () {
    expect(halo().shouldRepaint(halo()), isFalse);
  });

  test('the halo is repainted when any of its inputs changes', () {
    final changes = [
      halo(pulse: const AlwaysStoppedAnimation<double>(1)),
      halo(shape: BoxShape.circle),
      halo(radius: 12),
      halo(inset: const EdgeInsets.all(4)),
      halo(outline: _diamond),
      halo(glow: false),
    ];
    for (final old in changes) {
      expect(halo().shouldRepaint(old), isTrue, reason: '$old');
    }
  });

  test('a halo traces its outline, glow and line', () {
    for (final glow in [true, false]) {
      final recorder = PictureRecorder();
      halo(outline: _diamond, glow: glow)
          .paint(Canvas(recorder), const Size(80, 40));
      recorder.endRecording().dispose();
    }
  });
}

Path _diamond(Rect box) => Path()
  ..addPolygon(
      [box.topCenter, box.centerRight, box.bottomCenter, box.centerLeft], true);

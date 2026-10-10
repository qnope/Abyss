import 'package:abyss/presentation/widgets/guide/guide_halo_painter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const pulse = AlwaysStoppedAnimation<double>(0.5);

  GuideHaloPainter halo({
    Animation<double> pulse = pulse,
    BoxShape shape = BoxShape.rectangle,
    double radius = 8,
    EdgeInsets inset = EdgeInsets.zero,
    bool glow = true,
  }) =>
      GuideHaloPainter(
        pulse: pulse,
        shape: shape,
        radius: radius,
        inset: inset,
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
      halo(glow: false),
    ];
    for (final old in changes) {
      expect(halo().shouldRepaint(old), isTrue, reason: '$old');
    }
  });
}

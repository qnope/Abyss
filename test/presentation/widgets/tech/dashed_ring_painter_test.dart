import 'package:abyss/presentation/theme/abyss_colors.dart';
import 'package:abyss/presentation/widgets/tech/dashed_ring_painter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const ring = DashedRingPainter(color: AbyssColors.biolumCyan);

  test('the ring is not repainted while its look stays the same', () {
    expect(
      ring.shouldRepaint(const DashedRingPainter(color: AbyssColors.biolumCyan)),
      isFalse,
    );
  });

  test('the ring is repainted when its colour, stroke or dashes change', () {
    const changes = [
      DashedRingPainter(color: AbyssColors.biolumPink),
      DashedRingPainter(color: AbyssColors.biolumCyan, strokeWidth: 3),
      DashedRingPainter(color: AbyssColors.biolumCyan, dashCount: 10),
    ];
    for (final old in changes) {
      expect(ring.shouldRepaint(old), isTrue, reason: '$old');
    }
  });
}

import 'package:abyss/presentation/theme/abyss_island_colors.dart';
import 'package:abyss/presentation/widgets/base/base_sprite_paints.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final paints = BaseSpritePaints();

  test('a built building is drawn as it is', () {
    final paint = paints.of(level: 2, degraded: false);
    expect(paint.colorFilter, isNull);
    expect(paint.color.a, 1);
  });

  test('a building still to build is a faint cyan ghost', () {
    final paint = paints.of(level: 0, degraded: false);
    expect(paint.colorFilter, AbyssIslandColors.ghost);
    expect(paint.color.a, closeTo(BaseSpritePaints.ghostOpacity, 0.01));
    // A calm construction site: under a fifth of the sprite shows through.
    expect(
      AbyssIslandColors.ghostAlpha * BaseSpritePaints.ghostOpacity,
      lessThan(0.2),
    );
  });

  test('a degraded building is greyed', () {
    final paint = paints.of(level: 3, degraded: true);
    expect(paint.colorFilter, AbyssIslandColors.degraded);
    expect(paint.color.a, 1);
  });
}

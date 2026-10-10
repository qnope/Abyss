import 'package:abyss/presentation/theme/abyss_backdrop_theme.dart';
import 'package:abyss/presentation/theme/abyss_colors.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('veils the art with the abyss black, mostly opaque', () {
    final veil = AbyssBackdropTheme.dimColor;
    expect(veil.withValues(alpha: 1), AbyssColors.abyssBlack);
    expect(veil.a, closeTo(AbyssBackdropTheme.dimOpacity, 0.01));
  });

  test('waits for the art on a gradient sinking into the abyss', () {
    const fallback = AbyssBackdropTheme.fallback;
    expect(fallback.begin, Alignment.topCenter);
    expect(fallback.colors.last, AbyssColors.abyssBlack);
  });

  test('daylight from the surface is plain white', () {
    expect(AbyssColors.daylight, const Color(0xFFFFFFFF));
  });
}

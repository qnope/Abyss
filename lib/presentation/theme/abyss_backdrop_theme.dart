import 'package:flutter/painting.dart';

import 'abyss_colors.dart';

/// Colors of the illustrated deep sea drawn behind the menus.
abstract final class AbyssBackdropTheme {
  /// Opacity of the dark veil of a dimmed backdrop.
  static const dimOpacity = 0.85;

  /// The veil drawn over the art, so lists and text above stay readable.
  static final Color dimColor = AbyssColors.abyssBlack.withValues(
    alpha: dimOpacity,
  );

  /// Shown until the art is ready, matching its overall tones.
  static const fallback = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AbyssColors.trench, AbyssColors.deepNavy, AbyssColors.abyssBlack],
    stops: [0, 0.45, 1],
  );
}

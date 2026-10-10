import 'package:flutter/material.dart';
import 'abyss_colors.dart';
import 'abyss_text_theme.dart';

/// Styles of the full-screen menus drawn above the abyss backdrop: the
/// glowing game title, the large menu buttons and the footnotes.
abstract final class AbyssMenuTheme {
  static const _font = AbyssTextTheme.titleFont;

  static const double titleSpacing = 10;
  static const double subtitleSpacing = 3;

  /// The game name, glowing like bioluminescence.
  static final heroTitle = TextStyle(
    fontFamily: _font,
    fontSize: 60,
    height: 1.1,
    fontWeight: FontWeight.w700,
    letterSpacing: titleSpacing,
    color: AbyssColors.biolumCyan,
    shadows: [
      Shadow(
        color: AbyssColors.biolumCyan.withValues(alpha: 0.8),
        blurRadius: 16,
      ),
      Shadow(
        color: AbyssColors.biolumCyan.withValues(alpha: 0.45),
        blurRadius: 40,
      ),
    ],
  );

  static final heroSubtitle = TextStyle(
    fontFamily: _font,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    letterSpacing: subtitleSpacing,
    color: AbyssColors.abyssMist,
    shadows: [
      Shadow(
        color: AbyssColors.abyssBlack.withValues(alpha: 0.8),
        blurRadius: 6,
      ),
    ],
  );

  static const buttonRadius = BorderRadius.all(Radius.circular(12));
  static const double buttonMinHeight = 56;
  static const double buttonGap = 12;

  /// Label of a menu button, in capitals.
  static const buttonLabel = TextStyle(
    fontFamily: _font,
    fontSize: 20,
    height: 1.2,
    fontWeight: FontWeight.w700,
    letterSpacing: 3,
  );

  static const buttonSubtitle = TextStyle(fontSize: 13, height: 1.3);

  /// Text drawn on the glowing fill of a primary button.
  static const primaryForeground = AbyssColors.deepNavy;
  static final primarySubtitle = AbyssColors.deepNavy.withValues(alpha: 0.75);

  static final primaryDecoration = BoxDecoration(
    borderRadius: buttonRadius,
    gradient: const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [AbyssColors.biolumCyanLight, AbyssColors.biolumCyanDeep],
    ),
    boxShadow: [
      BoxShadow(
        color: AbyssColors.biolumCyan.withValues(alpha: 0.5),
        blurRadius: 24,
      ),
    ],
  );

  /// A dark glass pane rimmed with cyan, readable over the art.
  static final outlinedDecoration = BoxDecoration(
    borderRadius: buttonRadius,
    color: AbyssColors.abyssBlack.withValues(alpha: 0.6),
    border: Border.all(
      color: AbyssColors.biolumCyan.withValues(alpha: 0.9),
      width: 1.5,
    ),
  );

  static const badgeLabel = TextStyle(
    fontFamily: _font,
    fontSize: 14,
    height: 1,
    fontWeight: FontWeight.w700,
  );

  /// Discreet one-line footnote at the bottom of a menu.
  static final footnote = TextStyle(
    fontSize: 12.5,
    color: AbyssColors.onSurfaceDim,
    shadows: [
      Shadow(
        color: AbyssColors.abyssBlack.withValues(alpha: 0.9),
        blurRadius: 4,
      ),
    ],
  );
}

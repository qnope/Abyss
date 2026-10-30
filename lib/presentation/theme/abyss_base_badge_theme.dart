import 'package:flutter/painting.dart';

import 'abyss_colors.dart';
import 'abyss_text_theme.dart';

/// Colours and letters of the marks floating over the base's buildings:
/// the level plaque, the « À bâtir » pill, the green chevron of a
/// building to raise, the orange triangle of a degraded one and the
/// guide's ring. Taken from the approved mockup.
abstract final class AbyssBaseBadgeTheme {
  // The hexagonal level plaque, edged in the building's colour.
  static const Color plaqueTop = Color(0xFF1F3555);
  static const Color plaqueBottom = AbyssColors.deepNavy;
  static const Color plaqueSheen = Color(0x2EFFFFFF);
  static const Color plaqueText = Color(0xFFFFFFFF);

  // The dashed « À bâtir » pill of a plot, and its lock.
  static const Color pillFill = Color(0xE00D1B2A);
  static const Color pillEdge = Color(0x9900E5FF);
  static const Color pillText = AbyssColors.biolumCyanLight;
  static const Color lock = AbyssColors.onSurfaceDim;

  // The name of the building the guide points at, under its pill.
  static const Color nameFill = Color(0xB80A1524);
  static const Color nameText = AbyssColors.onSurfaceDim;

  // The chevron of a building that can be raised now.
  static const Color upgrade = AbyssColors.algaeGreen;
  static const Color upgradeFill = Color(0xFF0D3B2A);

  // The triangle of a degraded building.
  static const Color warning = Color(0xFFFFB74D);
  static const Color warningFill = Color(0xFF2A1A05);

  // The guide's ring around a slot: its line and its corner lights.
  static const Color ringDot = Color(0xFFE0FFFF);

  /// The level in its plaque.
  static const level = TextStyle(
    fontFamily: AbyssTextTheme.titleFont,
    fontWeight: FontWeight.w700,
    color: plaqueText,
    height: 1,
  );

  /// « À BÂTIR » in its pill.
  static const toBuild = TextStyle(
    fontFamily: AbyssTextTheme.titleFont,
    fontWeight: FontWeight.w700,
    color: pillText,
    height: 1,
  );

  /// The name of the building under its pill.
  static const name = TextStyle(
    fontFamily: AbyssTextTheme.titleFont,
    fontWeight: FontWeight.w600,
    color: nameText,
    height: 1,
  );

  /// The « ! » of the warning triangle.
  static const warningMark = TextStyle(
    fontFamily: AbyssTextTheme.titleFont,
    fontWeight: FontWeight.w700,
    color: warning,
    height: 1,
  );
}

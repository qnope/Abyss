import 'package:flutter/painting.dart';

import 'abyss_colors.dart';
import 'abyss_text_theme.dart';

/// Look of a bar of segments floating over a view, one of them selected,
/// such as the places of the army: a dark translucent tray, the selected
/// segment lit in cyan.
abstract final class AbyssSegmentedTheme {
  /// Height of the tray.
  static const height = 40.0;

  /// Corner radius of the tray, and of the selected segment inside it.
  static const radius = 12.0;
  static const segmentRadius = 9.0;

  /// Gap between the tray's edge and the selected segment.
  static const inset = 4.0;

  /// The tray, nearly opaque so that the view behind stays a hint.
  static const tray = Color(0xEB0D1B2A);
  static const trayEdge = AbyssColors.surfaceLight;

  /// The selected segment, and the texts on it.
  static const selected = AbyssColors.biolumCyan;
  static const onSelected = Color(0xFF03202A);

  /// The name of a segment, and the detail below it, such as a count.
  static const label = TextStyle(
    fontFamily: AbyssTextTheme.titleFont,
    fontSize: 13,
    fontWeight: FontWeight.w700,
    height: 1.1,
    color: Color(0xFF9FB8D6),
  );
  static const detail = TextStyle(
    fontFamily: AbyssTextTheme.titleFont,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.1,
    color: Color(0xFF5E7DA3),
  );
}

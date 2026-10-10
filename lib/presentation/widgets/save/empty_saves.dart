import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/abyss_colors.dart';
import '../menu/menu_button.dart';
import '../common/raster_svg.dart';

/// What the save list shows when no game is saved: a sonar that detects
/// nothing and a way to found a first colony.
///
/// Centered within [maxWidth]; the sonar shrinks on a short window and the
/// whole scrolls rather than overflows.
class EmptySaves extends StatelessWidget {
  final VoidCallback onNewGame;

  static const String illustration =
      'assets/illustrations/saves/empty_sonar.svg';
  static const double illustrationSize = 200;
  static const double maxWidth = 360;

  /// The smallest the sonar gets on a short window.
  static const double _minIllustrationSize = 120;

  /// Share of the available height the sonar takes at most.
  static const double _illustrationShare = 0.4;

  /// Slightly above the middle, where the eye lands first.
  static const Alignment _placement = Alignment(0, -0.3);

  const EmptySaves({super.key, required this.onNewGame});

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return LayoutBuilder(
      builder: (context, constraints) {
        final sonar = (constraints.maxHeight * _illustrationShare).clamp(
          _minIllustrationSize,
          illustrationSize,
        );
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(24, 8, 24, 24 + bottom),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: math.max(0, constraints.maxHeight - 32 - bottom),
            ),
            child: Align(
              alignment: _placement,
              child: _content(context, sonar),
            ),
          ),
        );
      },
    );
  }

  Widget _content(BuildContext context, double sonar) {
    final textTheme = Theme.of(context).textTheme;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: maxWidth),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RasterSvg(assetPath: illustration, size: sonar),
          const SizedBox(height: 24),
          Text(
            'Aucune colonie détectée',
            textAlign: TextAlign.center,
            style: textTheme.headlineLarge?.copyWith(fontSize: 26),
          ),
          const SizedBox(height: 8),
          Text(
            'Fondez votre première base dans les abysses.',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: AbyssColors.onSurfaceDim,
            ),
          ),
          const SizedBox(height: 28),
          MenuButton(label: 'NOUVELLE PARTIE', onPressed: onNewGame),
        ],
      ),
    );
  }
}

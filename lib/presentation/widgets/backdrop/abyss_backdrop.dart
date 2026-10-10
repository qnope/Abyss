import 'package:flutter/widgets.dart';

import '../../theme/abyss_backdrop_theme.dart';
import 'backdrop_image.dart';
import 'marine_snow.dart';

/// The illustrated deep sea behind the menus: the colony on its rocky
/// plateau above a trench, with marine snow rising and light breathing.
///
/// Fills its box (cropping the sides on a phone, the top and bottom on a
/// wide screen, always around the colony) and draws [child] on top. A
/// plain dark gradient shows until the art is rasterized, so there is
/// never a white flash. The art sits behind its own repaint boundary:
/// the [child] repainting never redraws it, nor the reverse.
class AbyssBackdrop extends StatelessWidget {
  static const defaultAsset = 'assets/illustrations/menu/abyss_backdrop.svg';

  /// Point of the art kept in view, in its 1600 x 2200 units: the base of
  /// the colony dome. On a wide screen the colony then sits just above the
  /// middle, between a menu title and its buttons, under the light rays.
  static const colonyFocus = Offset(800, 1200);

  final Widget child;

  /// Veils the art, so lists and text drawn above stay readable.
  final bool dimmed;

  /// Lets the marine snow and light move; they stand still otherwise, and
  /// whenever the system asks to reduce motion.
  final bool animate;

  final String asset;
  final Offset focus;

  const AbyssBackdrop({
    super.key,
    required this.child,
    this.dimmed = false,
    this.animate = true,
    this.asset = defaultAsset,
    this.focus = colonyFocus,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AbyssBackdropTheme.fallback),
      child: Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: [
          RepaintBoundary(
            child: Stack(
              alignment: Alignment.center,
              fit: StackFit.expand,
              children: [
                BackdropImage(asset: asset, focus: focus),
                MarineSnow(animate: animate),
                if (dimmed) ColoredBox(color: AbyssBackdropTheme.dimColor),
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }
}

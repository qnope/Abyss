import 'package:flutter/widgets.dart';

import '../../../theme/abyss_trench_theme.dart';

/// The haze of depth over a deep-sea scene, in screen space: bluish
/// toward the top of its box (where the eye looks far), clear in the
/// middle, darker at the bottom (see [AbyssTrenchTheme.haze]).
///
/// Fills its box. Lay it over a pannable content, outside its
/// InteractiveViewer: it stays still, is painted once in its own repaint
/// boundary and never takes a tap.
class DepthHaze extends StatelessWidget {
  const DepthHaze({super.key});

  @override
  Widget build(BuildContext context) => const IgnorePointer(
        child: RepaintBoundary(
          child: SizedBox.expand(
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: AbyssTrenchTheme.haze),
            ),
          ),
        ),
      );
}

import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../theme/abyss_menu_theme.dart';

/// Arranges a full-screen menu over the backdrop art: the [header] near
/// the top, the [actions] stacked at the bottom above an optional
/// [footer], leaving the middle of the art in view. An optional [corner]
/// (a discreet button) stays in the top right corner, above the scroll.
///
/// The column keeps to [maxWidth], centred on wide screens. On a screen
/// too short for it all, the free middle shrinks first, the spacing
/// tightens below [compactHeight] (a phone held sideways), then the whole
/// menu scrolls.
class MenuLayout extends StatelessWidget {
  static const double maxWidth = 420;
  static const columnKey = Key('menu-layout-column');

  /// Share of the height left above the [header].
  static const double headerTopShare = 0.1;

  /// Room always kept between the [header] and the [actions].
  static const double minMiddleGap = 24;

  /// Height under which every gap of the menu tightens.
  static const double compactHeight = 480;

  final Widget header;
  final List<Widget> actions;
  final Widget? footer;
  final Widget? corner;

  const MenuLayout({
    super.key,
    required this.header,
    required this.actions,
    this.footer,
    this.corner,
  });

  @override
  Widget build(BuildContext context) {
    final corner = this.corner;
    final menu = LayoutBuilder(
      builder:
          (context, box) => SingleChildScrollView(
            child: Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                key: columnKey,
                width: math.min(box.maxWidth, maxWidth),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: box.maxHeight),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _column(box.maxHeight),
                  ),
                ),
              ),
            ),
          ),
    );
    return SafeArea(
      child: Stack(
        fit: StackFit.expand,
        children: [
          menu,
          if (corner != null) Positioned(top: 4, right: 4, child: corner),
        ],
      ),
    );
  }

  /// Without flexible children, a column taller than its content spreads
  /// the spare room between them: no intrinsic layout pass is needed.
  Widget _column(double height) {
    final footer = this.footer;
    final compact = height < compactHeight;
    final top = compact ? 12.0 : math.max(16.0, height * headerTopShare);
    final gap = compact ? 8.0 : AbyssMenuTheme.buttonGap;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(padding: EdgeInsets.only(top: top), child: header),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: compact ? 12 : minMiddleGap),
            for (final (index, action) in actions.indexed) ...[
              if (index > 0) SizedBox(height: gap),
              action,
            ],
            if (footer != null) ...[
              SizedBox(height: compact ? 10 : 20),
              footer,
            ],
            SizedBox(height: compact ? 8 : 16),
          ],
        ),
      ],
    );
  }
}

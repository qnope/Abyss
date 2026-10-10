import 'package:flutter/material.dart';

import '../../theme/abyss_colors.dart';
import '../../theme/abyss_menu_theme.dart';
import 'count_badge.dart';

enum MenuButtonVariant {
  /// Glowing cyan fill: the action the screen suggests.
  primary,

  /// Dark pane rimmed with cyan: the other choices.
  outlined,
}

/// A large full-width menu button, with an optional second line (such as
/// the game a "continue" resumes) and an optional count badge.
class MenuButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final MenuButtonVariant variant;
  final String? subtitle;

  /// Shown in a badge after the label, unless zero.
  final int badgeCount;

  const MenuButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = MenuButtonVariant.primary,
    this.subtitle,
    this.badgeCount = 0,
  });

  bool get _primary => variant == MenuButtonVariant.primary;

  @override
  Widget build(BuildContext context) {
    final foreground =
        _primary ? AbyssMenuTheme.primaryForeground : AbyssColors.biolumCyan;
    // The glow is painted outside the Material, whose ink layer clips to
    // the button, and the ripple redraws this button only.
    return RepaintBoundary(
      child: Semantics(
        button: true,
        child: DecoratedBox(
          decoration:
              _primary
                  ? AbyssMenuTheme.primaryDecoration
                  : AbyssMenuTheme.outlinedDecoration,
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: onPressed,
              borderRadius: AbyssMenuTheme.buttonRadius,
              splashColor: foreground.withValues(alpha: 0.15),
              highlightColor: foreground.withValues(alpha: 0.08),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minWidth: double.infinity,
                  minHeight: AbyssMenuTheme.buttonMinHeight,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: _content(foreground),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _content(Color foreground) {
    final subtitle = this.subtitle;
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                maxLines: 1,
                style: AbyssMenuTheme.buttonLabel.copyWith(color: foreground),
              ),
              if (badgeCount > 0) ...[
                const SizedBox(width: 10),
                CountBadge(count: badgeCount, color: foreground),
              ],
            ],
          ),
        ),
        if (subtitle != null)
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AbyssMenuTheme.buttonSubtitle.copyWith(
              color:
                  _primary
                      ? AbyssMenuTheme.primarySubtitle
                      : AbyssColors.onSurfaceDim,
            ),
          ),
      ],
    );
  }
}

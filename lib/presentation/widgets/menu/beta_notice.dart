import 'package:flutter/material.dart';

import '../../app_version.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/abyss_colors.dart';
import '../../theme/abyss_menu_theme.dart';

/// One discreet line warning that the game is a beta whose saves may be
/// wiped.
class BetaNotice extends StatelessWidget {
  const BetaNotice({super.key});

  @override
  Widget build(BuildContext context) {
    final style = AbyssMenuTheme.footnote;
    final l10n = context.l10n;
    return Text.rich(
      TextSpan(
        style: style,
        children: [
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Icon(
              Icons.warning_amber_rounded,
              size: style.fontSize! + 2,
              color: AbyssColors.warning,
            ),
          ),
          TextSpan(
            text: ' ${l10n.menuBetaVersion(appVersion)}',
            style: const TextStyle(color: AbyssColors.warning),
          ),
          TextSpan(text: ' · ${l10n.menuBetaWarning}'),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}

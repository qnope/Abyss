import 'package:flutter/material.dart';

import '../../l10n/l10n_extension.dart';
import '../../theme/abyss_button_theme.dart';

/// "Passer ›": skips the story of a turn told on the map, straight to
/// its summary.
class StorySkipButton extends StatelessWidget {
  final VoidCallback onPressed;

  const StorySkipButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) => OutlinedButton(
        style: AbyssButtonTheme.overMap(),
        onPressed: onPressed,
        child: Text(context.l10n.turnStorySkip),
      );
}

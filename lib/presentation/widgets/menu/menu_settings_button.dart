import 'package:flutter/material.dart';
import '../../../data/language_settings.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/abyss_menu_theme.dart';
import '../common/language_dialog.dart';

/// A discreet gear over the menu art, opening the settings reachable
/// outside a game: the language of [settings].
class MenuSettingsButton extends StatelessWidget {
  const MenuSettingsButton({super.key, required this.settings});

  final LanguageSettings settings;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: context.l10n.screenSettings,
      icon: Icon(
        Icons.settings,
        color: AbyssMenuTheme.cornerIconColor,
        shadows: AbyssMenuTheme.cornerIconShadows,
      ),
      onPressed: () => showLanguageDialog(context, settings),
    );
  }
}

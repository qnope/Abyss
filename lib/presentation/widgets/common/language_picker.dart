import 'package:flutter/material.dart';
import '../../../data/language_settings.dart';
import '../../../domain/settings/language_choice.dart';
import '../../extensions/language_choice_extensions.dart';
import '../../l10n/language_choice_locale.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/abyss_colors.dart';

/// The "Langue" section of a settings screen: automatic, then each
/// language named in itself, the current [settings] choice checked.
///
/// Tapping a row picks it through [settings], saved at once. Only this
/// section rebuilds when the choice changes; the app itself switches
/// language when it listens to [settings] too.
class LanguagePicker extends StatelessWidget {
  const LanguagePicker({super.key, required this.settings});

  final LanguageSettings settings;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<LanguageChoice>(
      valueListenable: settings,
      child: Text(
        context.l10n.settingsLanguageTitle,
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(color: AbyssColors.onSurfaceDim),
      ),
      builder:
          (context, current, title) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              title!,
              for (final choice in LanguageChoice.values)
                _LanguageRow(
                  choice: choice,
                  selected: choice == current,
                  onTap: () => settings.choose(choice),
                ),
            ],
          ),
    );
  }
}

/// One choice of the [LanguagePicker], checked when [selected].
class _LanguageRow extends StatelessWidget {
  const _LanguageRow({
    required this.choice,
    required this.selected,
    required this.onTap,
  });

  final LanguageChoice choice;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      selected: selected,
      selectedColor: AbyssColors.biolumCyan,
      // The locale lets screen readers speak each endonym in its language.
      title: Text(
        choice.label(l10n),
        locale: choice.locale,
        style: textTheme.titleMedium?.copyWith(
          color: selected ? AbyssColors.biolumCyan : null,
        ),
      ),
      subtitle:
          choice == LanguageChoice.automatic
              ? Text(
                l10n.settingsLanguageAutomaticHint,
                style: textTheme.bodySmall?.copyWith(
                  color: AbyssColors.onSurfaceDim,
                ),
              )
              : null,
      trailing:
          selected
              ? const Icon(Icons.check, color: AbyssColors.biolumCyan)
              : null,
      onTap: onTap,
    );
  }
}

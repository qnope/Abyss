import 'package:flutter/material.dart';
import '../../domain/map/transition_base_type.dart';
import '../l10n/app_localizations.dart';
import '../theme/abyss_colors.dart';

extension TransitionBaseTypeExtensions on TransitionBaseType {
  String displayName(AppLocalizations l10n) => switch (this) {
    TransitionBaseType.faille => l10n.transitionBaseFailleName,
    TransitionBaseType.cheminee => l10n.transitionBaseChemineeName,
  };

  String description(AppLocalizations l10n) => switch (this) {
    TransitionBaseType.faille => l10n.transitionBaseFailleDescription,
    TransitionBaseType.cheminee => l10n.transitionBaseChemineeDescription,
  };

  Color get glowColor => switch (this) {
    TransitionBaseType.faille => AbyssColors.biolumCyan,
    TransitionBaseType.cheminee => AbyssColors.energyYellow,
  };
}

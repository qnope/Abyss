import 'package:flutter/material.dart';
import '../../domain/tech/tech_branch.dart';
import '../l10n/app_localizations.dart';
import '../theme/abyss_colors.dart';

extension TechBranchColor on TechBranch {
  Color get color => switch (this) {
    TechBranch.military => AbyssColors.biolumPink,
    TechBranch.resources => AbyssColors.algaeGreen,
    TechBranch.explorer => AbyssColors.biolumCyan,
  };
}

extension TechBranchInfo on TechBranch {
  String displayName(AppLocalizations l10n) => switch (this) {
    TechBranch.military => l10n.techBranchMilitaryName,
    TechBranch.resources => l10n.techBranchResourcesName,
    TechBranch.explorer => l10n.techBranchExplorerName,
  };

  String description(AppLocalizations l10n) => switch (this) {
    TechBranch.military => l10n.techBranchMilitaryDescription,
    TechBranch.resources => l10n.techBranchResourcesDescription,
    TechBranch.explorer => l10n.techBranchExplorerDescription,
  };

  String get iconPath => switch (this) {
    TechBranch.military => 'assets/icons/buildings/barracks.svg',
    TechBranch.resources => 'assets/icons/resources/algae.svg',
    TechBranch.explorer => 'assets/icons/units/scout.svg',
  };
}

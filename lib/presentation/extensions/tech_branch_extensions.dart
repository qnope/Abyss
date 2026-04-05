import 'package:flutter/material.dart';
import '../../domain/tech/tech_branch.dart';
import '../theme/abyss_colors.dart';

extension TechBranchColor on TechBranch {
  Color get color => switch (this) {
    TechBranch.military => AbyssColors.biolumPink,
    TechBranch.resources => AbyssColors.algaeGreen,
    TechBranch.explorer => AbyssColors.biolumCyan,
  };
}

extension TechBranchInfo on TechBranch {
  String get displayName => switch (this) {
    TechBranch.military => 'Militaire',
    TechBranch.resources => 'Ressources',
    TechBranch.explorer => 'Explorateur',
  };

  String get description => switch (this) {
    TechBranch.military =>
      'Améliore l\'attaque et la défense de toutes les unités.',
    TechBranch.resources =>
      'Améliore la production de toutes les ressources.',
    TechBranch.explorer =>
      'Améliore la portée d\'exploration de la carte.',
  };

  String get iconPath => switch (this) {
    TechBranch.military => 'assets/icons/buildings/barracks.svg',
    TechBranch.resources => 'assets/icons/resources/algae.svg',
    TechBranch.explorer => 'assets/icons/units/scout.svg',
  };
}

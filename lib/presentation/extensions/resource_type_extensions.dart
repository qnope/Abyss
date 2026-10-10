import 'package:flutter/material.dart';
import '../../domain/resource/resource_type.dart';
import '../l10n/app_localizations.dart';
import '../theme/abyss_colors.dart';

extension ResourceTypeColor on ResourceType {
  Color get color => switch (this) {
    ResourceType.algae => AbyssColors.algaeGreen,
    ResourceType.coral => AbyssColors.coralPink,
    ResourceType.ore => AbyssColors.oreBlue,
    ResourceType.energy => AbyssColors.energyYellow,
    ResourceType.pearl => AbyssColors.pearlWhite,
  };
}

extension ResourceTypeInfo on ResourceType {
  String displayName(AppLocalizations l10n) => switch (this) {
    ResourceType.algae => l10n.resourceAlgaeName,
    ResourceType.coral => l10n.resourceCoralName,
    ResourceType.ore => l10n.resourceOreName,
    ResourceType.energy => l10n.resourceEnergyName,
    ResourceType.pearl => l10n.resourcePearlName,
  };

  String flavorText(AppLocalizations l10n) => switch (this) {
    ResourceType.algae => l10n.resourceAlgaeFlavor,
    ResourceType.coral => l10n.resourceCoralFlavor,
    ResourceType.ore => l10n.resourceOreFlavor,
    ResourceType.energy => l10n.resourceEnergyFlavor,
    ResourceType.pearl => l10n.resourcePearlFlavor,
  };
}

extension ResourceGainsLabel on Map<ResourceType, int> {
  /// The gains in the order of the map: « +30 corail, +20 minerai ».
  /// What was not gained is left out.
  String gainLabel(AppLocalizations l10n) => [
    for (final MapEntry(:key, :value) in entries)
      if (value > 0) '+$value ${key.displayName(l10n).toLowerCase()}',
  ].join(', ');
}

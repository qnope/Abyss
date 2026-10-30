import '../../domain/building/building.dart';
import '../l10n/app_localizations.dart';
import 'building_type_extensions.dart';

extension BuildingBaseTexts on Building {
  /// What a screen reader says of the building on the base: its name,
  /// its level or that it is still to build, and whether it is
  /// [degraded].
  String baseLabel(AppLocalizations l10n, {required bool degraded}) => [
    type.displayName(l10n),
    level > 0 ? l10n.baseLevel(level) : l10n.baseNotBuilt,
    if (degraded) l10n.buildingDegraded,
  ].join(', ');
}

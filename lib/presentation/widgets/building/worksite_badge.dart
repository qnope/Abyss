import 'package:flutter/material.dart';
import '../../../domain/building/building.dart';
import '../../../domain/building/building_type.dart';
import '../../../domain/worksite/worksite.dart';
import '../../../domain/worksite/worksite_rules.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/abyss_colors.dart';

/// "Chantiers libres : X/Y" badge: building upgrades still allowed this
/// turn. With [showNext], also tells which HQ level opens the next one.
class WorksiteBadge extends StatelessWidget {
  final Worksite worksite;
  final Map<BuildingType, Building> buildings;
  final bool showNext;

  const WorksiteBadge({
    super.key,
    required this.worksite,
    required this.buildings,
    this.showNext = false,
  });

  int get _hqLevel => buildings[BuildingType.headquarters]?.level ?? 0;

  @override
  Widget build(BuildContext context) {
    final free = worksite.freeBuildSites(_hqLevel);
    final total = WorksiteRules.buildSites(_hqLevel);
    final color = free > 0 ? AbyssColors.biolumCyan : AbyssColors.warning;
    final next = WorksiteRules.nextSiteAtHq(_hqLevel);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AbyssColors.surfaceDim,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.construction, size: 16, color: color),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              _label(context.l10n, free, total, next),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  String _label(AppLocalizations l10n, int free, int total, int? next) {
    final base = l10n.baseWorksitesFree(free, total);
    if (!showNext || next == null) return base;
    return '$base · ${l10n.baseWorksitesNext(next)}';
  }
}

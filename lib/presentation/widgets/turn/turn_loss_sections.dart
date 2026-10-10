import 'package:flutter/material.dart';
import '../../../domain/building/building_type.dart';
import '../../../domain/unit/unit_type.dart';
import '../../extensions/building_type_extensions.dart';
import '../../extensions/unit_type_extensions.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/abyss_colors.dart';

/// The buildings switched off at the end of the turn, under a warning.
class DeactivatedBuildingsSection extends StatelessWidget {
  final List<BuildingType> buildings;

  const DeactivatedBuildingsSection({super.key, required this.buildings});

  @override
  Widget build(BuildContext context) => _LossSection(
    icon: Icons.warning,
    title: context.l10n.turnBuildingsDeactivated,
    color: AbyssColors.warning,
    lines: [for (final type in buildings) type.displayName(context.l10n)],
  );
}

/// The units lost at the end of the turn, with how many of each.
class LostUnitsSection extends StatelessWidget {
  final Map<UnitType, int> units;

  const LostUnitsSection({super.key, required this.units});

  @override
  Widget build(BuildContext context) => _LossSection(
    icon: Icons.error,
    title: context.l10n.turnUnitsLost,
    color: AbyssColors.error,
    lines: [
      for (final MapEntry(:key, :value) in units.entries)
        '${key.displayName(context.l10n)}: -$value',
    ],
  );
}

/// A divider, a titled header and one colored line per loss.
class _LossSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final List<String> lines;

  const _LossSection({
    required this.icon,
    required this.title,
    required this.color,
    required this.lines,
  });

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(color: color);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        Row(children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Text(title, style: style),
        ]),
        for (final line in lines) Text(line, style: style),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../../../domain/building/building_type.dart';
import '../../../domain/faction/faction_attack_report.dart';
import '../../../domain/map/post_holder.dart';
import '../../../domain/map/transition_base_name.dart';
import '../../extensions/attacker_name_texts.dart';
import '../../extensions/post_holder_extensions.dart';
import '../../extensions/transition_base_name_extensions.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/abyss_colors.dart';
import 'summary_line.dart';

/// The lines of one attack on the human in the end-of-turn summary: what
/// it hit (the base, a post or the kernel) and how it ended, then what
/// the human lost with it.
class AttackReportLines extends StatelessWidget {
  final FactionAttackReport report;

  const AttackReportLines({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final (icon, text, color) = _headline(l10n);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SummaryLine(icon, text, color, illustration: _postArt()),
        for (final loss in _losses(l10n))
          Padding(
            padding: const EdgeInsets.only(left: 28),
            child: SummaryLine(
              Icons.remove_circle_outline,
              loss,
              AbyssColors.error,
            ),
          ),
      ],
    );
  }

  (IconData, String, Color) _headline(AppLocalizations l10n) {
    final name = attackerLabel(l10n, report.attackerName);
    return switch (report.outcome) {
      AttackOutcome.repelled => (
        Icons.shield,
        _repelled(l10n, name),
        AbyssColors.success,
      ),
      AttackOutcome.damaged => (
        Icons.broken_image,
        l10n.factionAttackDamaged(name),
        AbyssColors.warning,
      ),
      AttackOutcome.pillaged => (
        Icons.dangerous,
        l10n.factionAttackPillaged(name),
        AbyssColors.error,
      ),
      AttackOutcome.postTaken => (
        Icons.flag,
        l10n.factionPostTaken(name, _postName(l10n)),
        AbyssColors.error,
      ),
      AttackOutcome.kernelDamaged => (
        Icons.broken_image,
        l10n.factionKernelDamaged(name),
        AbyssColors.warning,
      ),
      AttackOutcome.kernelTaken => (
        Icons.dangerous,
        l10n.factionKernelTaken(name),
        AbyssColors.error,
      ),
    };
  }

  String _repelled(AppLocalizations l10n, String name) => switch (report
      .target) {
    AttackTarget.base => l10n.factionAttackRepelled(name),
    AttackTarget.post => l10n.factionPostRepelled(name, _postName(l10n)),
    AttackTarget.kernel => l10n.factionKernelRepelled(name),
  };

  /// The post attacked, lit red if the faction took it, green if held.
  String? _postArt() {
    if (report.target != AttackTarget.post) return null;
    final type = TransitionBaseName.parse(report.entry.postName!)?.type;
    final taken = report.outcome == AttackOutcome.postTaken;
    return type?.svgPathFor(taken ? PostHolder.faction : PostHolder.human);
  }

  String _postName(AppLocalizations l10n) =>
      baseNameLabel(l10n, report.entry.postName!);

  /// The passage destroyed and the units lost, when there are any.
  List<String> _losses(AppLocalizations l10n) {
    final passage = report.passageLost;
    final level = report.levelBelow;
    final units = report.unitsLost;
    return [
      if (passage != null)
        passage == BuildingType.descentModule
            ? l10n.factionPostDescentModuleLost
            : l10n.factionPostPressureCapsuleLost,
      if (units > 0 && level != null) l10n.factionPostUnitsLost(units, level),
      if (units > 0 && report.target == AttackTarget.kernel)
        l10n.factionKernelGarrisonLost(units),
    ];
  }
}

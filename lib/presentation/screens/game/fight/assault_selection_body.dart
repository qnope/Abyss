import 'package:flutter/material.dart';

import '../../../../domain/fight/assault/assault_plan.dart';
import '../../../../domain/fight/assault/assault_target.dart';
import '../../../../domain/fight/unit_boost.dart';
import '../../../../domain/game/player.dart';
import '../../../../domain/unit/unit_type.dart';
import '../../../l10n/l10n_extension.dart';
import '../../../widgets/fight/army_selection_actions.dart';
import '../../../widgets/fight/assault_plan_panel.dart';
import '../../../widgets/fight/selection_summary_card.dart';
import '../../../widgets/fight/unit_quantity_row.dart';
import 'army_selection_summary.dart';

/// Body of the army selection of an assault led by an Abyss Admiral on
/// [target]: the plan for the [selected] army, recomputed at each change,
/// the units of [level] to pick, their totals, then the launch button,
/// kept at the bottom of the screen.
class AssaultSelectionBody extends StatelessWidget {
  static const ArmySelectionSummary _summary = ArmySelectionSummary();

  final Player player;
  final int level;
  final AssaultTarget? target;
  final Map<UnitType, int> selected;
  final void Function(UnitType type, int count) onChanged;
  final VoidCallback onLaunch;

  const AssaultSelectionBody({
    super.key,
    required this.player,
    required this.level,
    required this.target,
    required this.selected,
    required this.onChanged,
    required this.onLaunch,
  });

  bool get _hasAdmiral => (selected[UnitType.abyssAdmiral] ?? 0) > 0;

  @override
  Widget build(BuildContext context) {
    final UnitBoost boost = _summary.boostOf(player);
    final AssaultTarget? target = this.target;
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              if (target != null) ...[
                AssaultPlanPanel(
                  plan: AssaultPlan.of(
                    player: player,
                    level: level,
                    target: target,
                    army: selected,
                  ),
                  level: level,
                ),
                const Divider(height: 24),
              ],
              for (final e in player.unitsOnLevel(level).entries)
                if (e.value.count > 0)
                  UnitQuantityRow(
                    type: e.key,
                    stock: e.value.count,
                    value: selected[e.key] ?? 0,
                    onChanged: (int v) => onChanged(e.key, v),
                  ),
              const SizedBox(height: 12),
              SelectionSummaryCard(
                totalAtk: _summary.totalAtk(selected, boost),
                totalDef: _summary.totalDef(selected, boost),
                boost: boost,
              ),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: ArmySelectionActions(
              launchLabel: context.l10n.fightLaunchAssault,
              admiralMissing: !_hasAdmiral,
              onLaunch: _hasAdmiral ? onLaunch : null,
            ),
          ),
        ),
      ],
    );
  }
}

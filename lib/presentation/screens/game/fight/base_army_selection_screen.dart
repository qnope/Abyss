import 'package:flutter/material.dart';
import '../../../../data/game_repository.dart';
import '../../../../domain/action/action_executor.dart';
import '../../../../domain/action/attack_base_action.dart';
import '../../../../domain/action/attack_base_entries.dart';
import '../../../../domain/action/attack_base_result.dart';
import '../../../../domain/game/game.dart';
import '../../../../domain/game/player.dart';
import '../../../../domain/replay/seeded_random.dart';
import '../../../../domain/unit/unit_type.dart';
import '../../../extensions/action_failure_extensions.dart';
import '../../../l10n/l10n_extension.dart';
import '../../../widgets/fight/army_selection_actions.dart';
import '../../../widgets/fight/selection_summary_card.dart';
import '../../../widgets/fight/unit_quantity_row.dart';
import 'army_selection_summary.dart';
import 'base_assault_summary_screen.dart';

/// Picks the army of the base level to send against the base of
/// [target], then settles the assault and shows its report. No admiral is
/// needed to attack a base.
class BaseArmySelectionScreen extends StatefulWidget {
  final Game game;
  final GameRepository repository;
  final Player target;
  final VoidCallback onChanged;

  const BaseArmySelectionScreen({
    super.key,
    required this.game,
    required this.repository,
    required this.target,
    required this.onChanged,
  });

  @override
  State<BaseArmySelectionScreen> createState() =>
      _BaseArmySelectionScreenState();
}

class _BaseArmySelectionScreenState extends State<BaseArmySelectionScreen> {
  static const ArmySelectionSummary _summary = ArmySelectionSummary();
  final Map<UnitType, int> _selected = <UnitType, int>{};

  Map<UnitType, int> get _picked => {
    for (final e in _selected.entries)
      if (e.value > 0) e.key: e.value,
  };

  @override
  Widget build(BuildContext context) {
    final units = widget.game.humanPlayer.unitsOnLevel(
      AttackBaseAction.level,
    );
    final boost = _summary.boostOf(widget.game.humanPlayer);
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.fightAssaultOn(widget.target.name)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          for (final e in units.entries)
            if (e.value.count > 0)
              UnitQuantityRow(
                type: e.key,
                stock: e.value.count,
                value: _selected[e.key] ?? 0,
                onChanged: (v) => setState(() => _selected[e.key] = v),
              ),
          const SizedBox(height: 12),
          SelectionSummaryCard(
            totalAtk: _summary.totalAtk(_selected, boost),
            totalDef: _summary.totalDef(_selected, boost),
            boost: boost,
          ),
          ArmySelectionActions(
            launchLabel: context.l10n.fightLaunchAssault,
            onLaunch: _picked.isEmpty ? null : _launch,
          ),
        ],
      ),
    );
  }

  Future<void> _launch() async {
    final result = ActionExecutor().execute(
      AttackBaseAction(
        targetPlayerId: widget.target.id,
        selectedUnits: _picked,
        random: SeededRandom.fresh(),
      ),
      widget.game,
      widget.game.humanPlayer,
    );
    if (!result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.failureMessage(context.l10n))),
      );
      return;
    }
    await widget.repository.save(widget.game);
    widget.onChanged();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => BaseAssaultSummaryScreen(
          entry: AttackBaseEntries.forAttacker(
            widget.game.turn,
            widget.target.name,
            result as AttackBaseResult,
          ),
        ),
      ),
    );
  }
}

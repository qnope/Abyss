import 'package:flutter/material.dart';
import '../../../../data/game_repository.dart';
import '../../../../domain/action/action_executor.dart';
import '../../../../domain/action/attack_volcanic_kernel_action.dart';
import '../../../../domain/action/attack_volcanic_kernel_result.dart';
import '../../../../domain/fight/assault/assault_target.dart';
import '../../../../domain/game/game.dart';
import '../../../../domain/unit/unit_type.dart';
import '../../../../domain/replay/seeded_random.dart';
import '../../../extensions/action_failure_extensions.dart';
import '../../../l10n/l10n_extension.dart';
import 'assault_selection_body.dart';
import 'kernel_fight_summary_screen.dart';

class KernelArmySelectionScreen extends StatefulWidget {
  final Game game;
  final GameRepository repository;
  final int targetX;
  final int targetY;
  final int level;
  final VoidCallback onChanged;

  const KernelArmySelectionScreen({
    super.key,
    required this.game,
    required this.repository,
    required this.targetX,
    required this.targetY,
    required this.level,
    required this.onChanged,
  });

  @override
  State<KernelArmySelectionScreen> createState() =>
      _KernelArmySelectionScreenState();
}

class _KernelArmySelectionScreenState
    extends State<KernelArmySelectionScreen> {
  final Map<UnitType, int> _selected = <UnitType, int>{};

  @override
  void initState() {
    super.initState();
    final units = widget.game.humanPlayer.unitsOnLevel(widget.level);
    for (final type in units.keys) {
      _selected[type] = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n
            .fightAssaultOn(context.l10n.buildingVolcanicKernelName)),
      ),
      body: AssaultSelectionBody(
        player: widget.game.humanPlayer,
        level: widget.level,
        target: AssaultTarget.kernel,
        selected: _selected,
        onChanged: (UnitType type, int count) =>
            setState(() => _selected[type] = count),
        onLaunch: _onLaunchPressed,
      ),
    );
  }

  Future<void> _onLaunchPressed() async {
    final nonZero = <UnitType, int>{
      for (final e in _selected.entries)
        if (e.value > 0) e.key: e.value,
    };
    final action = AttackVolcanicKernelAction(
      targetX: widget.targetX,
      targetY: widget.targetY,
      level: widget.level,
      selectedUnits: nonZero,
      random: SeededRandom.fresh(),
    );
    final result = ActionExecutor().execute(
      action, widget.game, widget.game.humanPlayer,
    );
    if (!result.isSuccess) {
      if (!mounted) return;
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
        builder: (_) => KernelFightSummaryScreen(
          result: result as AttackVolcanicKernelResult,
          targetX: widget.targetX,
          targetY: widget.targetY,
        ),
      ),
    );
  }
}

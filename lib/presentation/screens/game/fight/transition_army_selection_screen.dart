import 'package:flutter/material.dart';
import '../../../../data/game_repository.dart';
import '../../../../domain/action/action_executor.dart';
import '../../../../domain/action/attack_transition_base_action.dart';
import '../../../../domain/action/attack_transition_base_result.dart';
import '../../../../domain/game/game.dart';
import '../../../../domain/map/transition_base.dart';
import '../../../../domain/unit/unit_type.dart';
import '../../../widgets/fight/selection_summary_card.dart';
import '../../../widgets/fight/unit_quantity_row.dart';
import 'army_selection_summary.dart';
import 'transition_fight_summary_screen.dart';

class TransitionArmySelectionScreen extends StatefulWidget {
  final Game game;
  final GameRepository repository;
  final int targetX;
  final int targetY;
  final int level;
  final TransitionBase transitionBase;
  final VoidCallback onChanged;

  const TransitionArmySelectionScreen({
    super.key,
    required this.game,
    required this.repository,
    required this.targetX,
    required this.targetY,
    required this.level,
    required this.transitionBase,
    required this.onChanged,
  });

  @override
  State<TransitionArmySelectionScreen> createState() =>
      _TransitionArmySelectionScreenState();
}

class _TransitionArmySelectionScreenState
    extends State<TransitionArmySelectionScreen> {
  static const ArmySelectionSummary _summary = ArmySelectionSummary();
  final Map<UnitType, int> _selected = <UnitType, int>{};

  @override
  void initState() {
    super.initState();
    final units = widget.game.humanPlayer.unitsOnLevel(widget.level);
    for (final type in units.keys) {
      _selected[type] = 0;
    }
  }

  int get _totalSelected =>
      _selected.values.fold<int>(0, (sum, v) => sum + v);

  bool get _hasAdmiral =>
      (_selected[UnitType.abyssAdmiral] ?? 0) > 0;

  int get _militaryLevel =>
      _summary.militaryLevelOf(widget.game.humanPlayer);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Assaut: ${widget.transitionBase.name}')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final units = widget.game.humanPlayer.unitsOnLevel(widget.level);
    final rows = <Widget>[];
    for (final entry in units.entries) {
      final stock = entry.value.count;
      if (stock <= 0) continue;
      rows.add(UnitQuantityRow(
        type: entry.key,
        stock: stock,
        value: _selected[entry.key] ?? 0,
        onChanged: (v) => setState(() => _selected[entry.key] = v),
      ));
    }

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        ...rows,
        const SizedBox(height: 12),
        SelectionSummaryCard(
          totalAtk: _summary.totalAtk(_selected, _militaryLevel),
          totalDef: _summary.totalDef(_selected),
          militaryLevel: _militaryLevel,
        ),
        if (!_hasAdmiral) ...[
          const SizedBox(height: 8),
          Text(
            'Un Amiral des Abysses est requis pour lancer l\'assaut',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 16),
        _buildActions(),
      ],
    );
  }

  Widget _buildActions() {
    return Row(children: [
      Expanded(
        child: ElevatedButton(
          onPressed: _totalSelected == 0 || !_hasAdmiral
              ? null
              : _onLaunchPressed,
          child: const Text('Lancer l\'assaut'),
        ),
      ),
      const SizedBox(width: 12),
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Annuler'),
      ),
    ]);
  }

  Future<void> _onLaunchPressed() async {
    final nonZero = <UnitType, int>{
      for (final e in _selected.entries)
        if (e.value > 0) e.key: e.value,
    };
    final action = AttackTransitionBaseAction(
      targetX: widget.targetX,
      targetY: widget.targetY,
      level: widget.level,
      selectedUnits: nonZero,
    );
    final result = ActionExecutor().execute(
      action, widget.game, widget.game.humanPlayer,
    );
    if (!result.isSuccess) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.reason ?? 'Erreur')),
      );
      return;
    }
    await widget.repository.save(widget.game);
    widget.onChanged();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => TransitionFightSummaryScreen(
          result: result as AttackTransitionBaseResult,
          transitionBase: widget.transitionBase,
          targetX: widget.targetX,
          targetY: widget.targetY,
        ),
      ),
    );
  }
}

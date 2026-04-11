import 'package:flutter/material.dart';
import '../../../../data/game_repository.dart';
import '../../../../domain/action/action_executor.dart';
import '../../../../domain/action/fight_monster_action.dart';
import '../../../../domain/action/fight_monster_result.dart';
import '../../../../domain/game/game.dart';
import '../../../../domain/map/monster_lair.dart';
import '../../../../domain/unit/unit_type.dart';
import '../../../widgets/fight/monster_preview.dart';
import '../../../widgets/fight/selection_summary_card.dart';
import '../../../widgets/fight/unit_quantity_row.dart';
import 'army_selection_summary.dart';
import 'fight_summary_screen.dart';

class ArmySelectionScreen extends StatefulWidget {
  final Game game;
  final GameRepository repository;
  final int targetX;
  final int targetY;
  final int level;
  final MonsterLair lair;
  final VoidCallback onChanged;

  const ArmySelectionScreen({
    super.key,
    required this.game,
    required this.repository,
    required this.targetX,
    required this.targetY,
    required this.level,
    required this.lair,
    required this.onChanged,
  });

  @override
  State<ArmySelectionScreen> createState() => _ArmySelectionScreenState();
}

class _ArmySelectionScreenState extends State<ArmySelectionScreen> {
  static const ArmySelectionSummary _summary = ArmySelectionSummary();
  final Map<UnitType, int> _selected = <UnitType, int>{};

  @override
  void initState() {
    super.initState();
    for (final UnitType type in widget.game.humanPlayer.unitsOnLevel(widget.level).keys) {
      _selected[type] = 0;
    }
  }

  int get _totalSelected =>
      _selected.values.fold<int>(0, (int sum, int v) => sum + v);

  int get _militaryLevel =>
      _summary.militaryLevelOf(widget.game.humanPlayer);

  int get _totalAtk => _summary.totalAtk(_selected, _militaryLevel);

  int get _totalDef => _summary.totalDef(_selected);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Préparer le combat')),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final player = widget.game.humanPlayer;
    final List<Widget> rows = <Widget>[];
    for (final MapEntry<UnitType, dynamic> entry in player.unitsOnLevel(widget.level).entries) {
      final int stock = entry.value.count as int;
      if (stock <= 0) continue;
      final UnitType type = entry.key;
      rows.add(UnitQuantityRow(
        type: type,
        stock: stock,
        value: _selected[type] ?? 0,
        onChanged: (int v) => setState(() => _selected[type] = v),
      ));
    }

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        MonsterPreview(lair: widget.lair),
        const SizedBox(height: 12),
        ...rows,
        const SizedBox(height: 12),
        SelectionSummaryCard(
          totalAtk: _totalAtk,
          totalDef: _totalDef,
          militaryLevel: _militaryLevel,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed:
                    _totalSelected == 0 ? null : () => _onLaunchPressed(),
                child: const Text('Lancer le combat'),
              ),
            ),
            const SizedBox(width: 12),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _onLaunchPressed() async {
    final Map<UnitType, int> nonZero = <UnitType, int>{
      for (final MapEntry<UnitType, int> e in _selected.entries)
        if (e.value > 0) e.key: e.value,
    };
    final FightMonsterAction action = FightMonsterAction(
      targetX: widget.targetX,
      targetY: widget.targetY,
      level: widget.level,
      selectedUnits: nonZero,
    );
    final result = ActionExecutor().execute(
      action,
      widget.game,
      widget.game.humanPlayer,
    );
    await widget.repository.save(widget.game);
    widget.onChanged();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => FightSummaryScreen(
          result: result as FightMonsterResult,
          lair: widget.lair,
          targetX: widget.targetX,
          targetY: widget.targetY,
        ),
      ),
    );
  }
}

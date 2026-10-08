import 'dart:convert';
import 'dart:math';

import '../../replay/seeded_random.dart';
import '../game_script.dart';
import '../script_turn.dart';
import '../strategies/army_planner.dart';
import '../strategies/battle_moves.dart';
import 'plan_moves.dart';
import 'plan_step.dart';
import 'replay_variant.dart';

/// Plays the plan of an exported replay again, moved away from the
/// original game as [variant] says: another map, other dice, a smaller
/// army, later turns.
///
/// Unlike the exact replay, it plays on after the replay's last turn
/// until the game ends, and tries a failed step again on each later turn
/// for `variant.patience` turns, as a player sticking to a plan would.
/// The steps on the road to the volcano (assaults, descents) wait as long
/// as it takes.
class PlanScript extends GameScript {
  final ReplayVariant variant;
  final String player;
  final int? replayMapSeed;
  final Map<int, int> endTurnSeeds;
  final List<PlanStep> _pending;

  @override
  final String name;

  PlanScript._({
    required this.name,
    required this.variant,
    required this.player,
    required this.replayMapSeed,
    required this.endTurnSeeds,
    required List<PlanStep> steps,
  }) : _pending = steps;

  /// Reads an exported replay; [random] draws the delays of [variant].
  factory PlanScript.fromReplay(
    String source,
    ReplayVariant variant, {
    Random? random,
  }) {
    final Map<String, Object?> json =
        jsonDecode(source) as Map<String, Object?>;
    final Random draw = random ?? Random(0);
    final Map<String, Object?> turns = json['turns'] as Map<String, Object?>;
    final List<int> order = turns.keys.map(int.parse).toList()..sort();
    final List<PlanStep> steps = <PlanStep>[];
    for (final int t in order) {
      final int due =
          (t * variant.stretch).round() +
          (variant.jitter > 0 ? draw.nextInt(variant.jitter + 1) : 0);
      for (final Object? action in turns['$t'] as List<Object?>) {
        steps.add(
          PlanStep(
            turn: due,
            rank: steps.length,
            json: Map<String, Object?>.from(action as Map),
          ),
        );
      }
    }
    final Object? seeds = json['endTurnSeeds'];
    return PlanScript._(
      name: '${json['name'] ?? 'replay'} (${variant.label})',
      variant: variant,
      player: json['player'] as String? ?? 'replay',
      replayMapSeed: json['mapSeed'] as int?,
      endTurnSeeds: <int, int>{
        if (seeds is Map)
          for (final MapEntry<Object?, Object?> e in seeds.entries)
            int.parse(e.key.toString()): e.value as int,
      },
      steps: steps,
    );
  }

  @override
  String get playerName => player;

  @override
  int? get mapSeed => variant.sameMap ? replayMapSeed : null;

  @override
  Random? endTurnRandom(int turn) {
    final int? seed = endTurnSeeds[turn];
    final bool pinned = variant.sameMap && variant.sameDice;
    return pinned && seed != null ? SeededRandom(seed) : null;
  }

  /// Steps not played yet, in the order of the original game.
  List<PlanStep> get pending => List<PlanStep>.unmodifiable(_pending);

  @override
  void playTurn(ScriptTurn turn) {
    if (variant.defends && turn.player.raidState.isIncoming) {
      turn.defendBase(const ArmyPlanner());
    }
    final List<PlanStep> due =
        _pending.where((PlanStep s) => s.turn <= turn.number).toList()
          ..sort((PlanStep a, PlanStep b) => a.rank.compareTo(b.rank));
    for (final PlanStep step in due) {
      if (turn.isOver) return;
      final bool done = turn.playStep(step, variant);
      final bool late = turn.number - step.turn >= variant.patience;
      if (done || late && !step.persistent) {
        _pending.remove(step);
      }
    }
  }
}

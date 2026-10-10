import 'dart:math';

import '../action/action_executor.dart';
import '../replay/seeded_random.dart';
import '../script/script_log_entry.dart';
import '../script/script_turn.dart';

/// A turn of a faction: every action that rolls dice gets a freshly
/// seeded generator, so the journal can write the dice down and a replay
/// plays the same game without the brain.
class FactionTurn extends ScriptTurn {
  final Random _seeds;

  FactionTurn({
    required super.game,
    required super.player,
    required ActionExecutor super.executor,
    required Random seeds,
  }) : _seeds = seeds,
       super(random: seeds, log: <ScriptLogEntry>[]);

  @override
  Random get random => SeededRandom(_seeds.nextInt(0x7FFFFFFF));
}

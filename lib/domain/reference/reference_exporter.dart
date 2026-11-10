import 'dart:convert';

import '../game/game.dart';
import '../replay/replay_export.dart';
import '../script/scenario_parser.dart';
import '../script/script_run_report.dart';
import '../script/script_runner.dart';
import 'game_capture.dart';
import 'game_snapshot.dart';
import 'reference_game.dart';
import 'reference_milestones.dart';
import 'reference_recorder.dart';
import 'reference_source.dart';
import 'reference_trace.dart';
import 'replay_comparison.dart';
import 'seeded_script.dart';

/// What an export produced: the game, and the texts asked with it.
typedef ReferenceExport = ({ReferenceGame game, String? dump, String? trace});

/// Plays the game of a [ReferenceSource], then replays its journal the
/// way `bin/simulate.dart` replays an exported game (`ScenarioParser` and
/// `ScriptRunner`) and records the digests of that replay: they are what
/// any other replay of the journal must find.
class ReferenceExporter {
  /// Id of the human player of a reference game. A faction breaks a tie
  /// between two bases by their ids; like nearly every id the game draws,
  /// this one sorts before those of the factions.
  static const String humanId = '00000000-0000-4000-8000-000000000000';

  final TextDigest digest;

  /// Gives the text of a scenario file, by its path.
  final String Function(String path) read;

  /// Whether the game as first played is compared with its replay at the
  /// start of every turn, not only once it stopped.
  final bool everyTurn;

  const ReferenceExporter({
    required this.digest,
    required this.read,
    this.everyTurn = false,
  });

  /// [dumpTurn] is a turn number, or `final` for the last state.
  ReferenceExport export(
    ReferenceSource source, {
    int? traceTurn,
    Object? dumpTurn,
  }) {
    final GameCapture played =
        everyTurn ? ReferenceRecorder(digest) : GameCapture();
    _runner(source, played).run(
      SeededScript(source.script(read), seed: source.seed, executor: played),
      seed: source.seed,
    );
    if (!ReplayExport.isExact(played.game)) {
      throw StateError('The journal is not exact: a die was not seeded');
    }
    final Map<String, Object?> journal = ReplayExport.toJson(played.game);
    final ReferenceRecorder replayed = ReferenceRecorder(
      digest,
      traceTurn: traceTurn,
      dumpTurn: dumpTurn is int ? dumpTurn : null,
    );
    final ScriptRunReport report = _runner(
      source,
      replayed,
    ).run(ScenarioParser.parse(jsonEncode(journal)), seed: source.seed);
    final Game game = replayed.game;
    final Map<String, String> last = GameSnapshot.texts(game);
    final List<String> digests = last.values.map(digest).toList();
    if (played is ReferenceRecorder) {
      ReplayComparison.sameTurns(played.turns, replayed.turns);
    }
    ReplayComparison.same(
      'when it stopped',
      GameSnapshot.digests(played.game, digest),
      digests,
    );
    final Map<String, String>? dump =
        dumpTurn == 'final' ? last : replayed.dump;
    if (dumpTurn != null && dump == null) {
      throw StateError('Turn $dumpTurn was not played');
    }
    return (
      game: ReferenceGame(
        source: source,
        journal: journal,
        turns: replayed.turns,
        finalDigests: digests,
        actions: replayed.actions,
        events: replayed.events,
        milestones: ReferenceMilestones.of(game, report.milestones),
        status: game.status,
        turn: game.turn,
      ),
      dump: dump == null ? null : ReferenceTrace.dump(dumpTurn!, dump),
      trace:
          traceTurn == null
              ? null
              : ReferenceTrace.trace(
                replayed,
                traceTurn,
                game.replay!.actionsOf(traceTurn),
              ),
    );
  }

  ScriptRunner _runner(ReferenceSource source, GameCapture executor) =>
      ScriptRunner(
        maxTurns: source.turns,
        difficulty: source.difficulty,
        humanId: humanId,
        executor: executor,
      );
}

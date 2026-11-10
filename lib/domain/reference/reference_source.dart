import '../faction/faction_personality.dart';
import '../game/difficulty.dart';
import '../script/among_factions.dart';
import '../script/game_script.dart';
import '../script/scenario_parser.dart';
import '../script/script_library.dart';

/// How a reference game is produced: a built-in [strategy] or a
/// [scenario] file (a scenario or an exported replay), the seed, the
/// difficulty, the factions and the turn limit. The same source always
/// produces the same game.
class ReferenceSource {
  /// Name of a strategy of `ScriptLibrary`, when no [scenario] is given.
  final String? strategy;

  /// Path of a scenario or replay file, from the repository root.
  final String? scenario;

  final int seed;

  /// Difficulty of the game, unless the scenario pins its own.
  final Difficulty difficulty;

  /// The factions the strategy plays against, in playing order; a replay
  /// names its own.
  final List<FactionPersonality> factions;

  /// Turn limit; an exported replay stops on its own last turn.
  final int turns;

  const ReferenceSource({
    this.strategy,
    this.scenario,
    this.seed = 1,
    this.difficulty = Difficulty.normal,
    this.factions = const <FactionPersonality>[],
    this.turns = 60,
  }) : assert(
         (strategy == null) != (scenario == null),
         'a strategy or a scenario, not both',
       );

  factory ReferenceSource.fromJson(Map<String, Object?> json) =>
      ReferenceSource(
        strategy: json['strategy'] as String?,
        scenario: json['scenario'] as String?,
        seed: json['seed']! as int,
        difficulty: Difficulty.values.byName(json['difficulty']! as String),
        factions: <FactionPersonality>[
          for (final Object? name in json['factions']! as List<Object?>)
            FactionPersonality.values.byName(name! as String),
        ],
        turns: json['turns']! as int,
      );

  Map<String, Object?> toJson() => <String, Object?>{
    if (strategy != null) 'strategy': strategy,
    if (scenario != null) 'scenario': scenario,
    'seed': seed,
    'difficulty': difficulty.name,
    'factions': <String>[for (final f in factions) f.name],
    'turns': turns,
  };

  /// The script that plays the game; [read] gives the text of a file.
  GameScript script(String Function(String path) read) {
    final String? file = scenario;
    final GameScript inner =
        file != null
            ? ScenarioParser.parse(read(file))
            : ScriptLibrary.byName(strategy!);
    return factions.isEmpty ? inner : AmongFactions(inner, factions);
  }
}

import '../building/building_type.dart';
import '../game/game.dart';
import '../game/game_statistics.dart';
import '../game/game_statistics_calculator.dart';
import '../game/game_status.dart';
import '../resource/resource_type.dart';
import '../unit/unit_type.dart';
import 'script_log_entry.dart';

/// How one scripted game ended.
class ScriptRunReport {
  final String scriptName;
  final int seed;
  final GameStatus status;
  final GameStatistics statistics;

  /// Turns ended before the game stopped; a won game counts the turn the
  /// victory came on.
  final int turnsPlayed;

  /// Noise made over the whole game; it drives the raid strength.
  final int totalNoise;
  final Map<BuildingType, int> buildings;
  final Map<UnitType, int> baseUnits;
  final Map<ResourceType, int> resources;
  final List<ScriptLogEntry> log;

  const ScriptRunReport({
    required this.scriptName,
    required this.seed,
    required this.status,
    required this.statistics,
    required this.turnsPlayed,
    required this.totalNoise,
    required this.buildings,
    required this.baseUnits,
    required this.resources,
    required this.log,
  });

  factory ScriptRunReport.of(
    Game game, {
    required String scriptName,
    required int seed,
    required List<ScriptLogEntry> log,
  }) {
    final player = game.humanPlayer;
    return ScriptRunReport(
      scriptName: scriptName,
      seed: seed,
      status: game.status,
      statistics: const GameStatisticsCalculator().compute(game),
      turnsPlayed:
          game.status == GameStatus.victory ? game.turn : game.turn - 1,
      totalNoise: player.raidState.totalNoise,
      buildings: player.buildings.map((t, b) => MapEntry(t, b.level)),
      baseUnits: player.unitsOnLevel(1).map((t, u) => MapEntry(t, u.count)),
      resources: player.resources.map((t, r) => MapEntry(t, r.amount)),
      log: List<ScriptLogEntry>.unmodifiable(log),
    );
  }

  bool get isDefeat => status == GameStatus.defeat;
  bool get isVictory => status == GameStatus.victory;
  int get raidsRepelled => statistics.raidsRepelled;
  int get raidsLost => statistics.raidsLost;
  int get failedActions => log.where((e) => !e.success).length;

  Map<String, Object> toJson() => <String, Object>{
        'script': scriptName,
        'seed': seed,
        'status': status.name,
        'turnsPlayed': turnsPlayed,
        'raidsRepelled': raidsRepelled,
        'raidsLost': raidsLost,
        'monstersDefeated': statistics.monstersDefeated,
        'totalNoise': totalNoise,
        'failedActions': failedActions,
        'buildings': _byName(buildings),
        'baseUnits': _byName(baseUnits),
        'resources': _byName(resources),
      };

  static Map<String, int> _byName<T extends Enum>(Map<T, int> values) =>
      values.map((T k, int v) => MapEntry(k.name, v));
}

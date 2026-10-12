import '../faction/faction_attack_report.dart';
import '../game/game.dart';
import '../map/transition_base_type.dart';
import '../raid/raid_report.dart';
import '../volcano/volcano_report.dart';

/// One raid of a scripted game, or one kraken wave on its kernel, as the
/// turn summary showed it.
class ScriptRaid {
  final int turn;
  final int monsters;
  final int monsterLevel;
  final bool victory;

  const ScriptRaid({
    required this.turn,
    required this.monsters,
    required this.monsterLevel,
    required this.victory,
  });

  factory ScriptRaid.of(RaidReport report) => ScriptRaid(
        turn: report.turn,
        monsters: report.wave.totalCount,
        monsterLevel: report.wave.level,
        victory: report.victory,
      );

  factory ScriptRaid.ofWave(VolcanoReport report) => ScriptRaid(
        turn: report.turn,
        monsters: report.wave.totalCount,
        monsterLevel: report.wave.level,
        victory: report.victory,
      );

  Map<String, Object> toJson() => <String, Object>{
        'turn': turn,
        'monsters': monsters,
        'level': monsterLevel,
        'victory': victory,
      };
}

/// First turn each step of the road to the volcano was reached, every
/// raid of the game, and the guardians' strike back at the first Faille.
class ScriptMilestones {
  int? failleCaptured;
  int? chemineeCaptured;
  int? kernelCaptured;

  /// Turn the guardians struck the first Faille back, if they did, and
  /// whether it held.
  int? leviathanStruck;
  bool? leviathanHeld;
  final List<ScriptRaid> raids = <ScriptRaid>[];
  final List<ScriptRaid> waves = <ScriptRaid>[];

  ScriptMilestones();

  /// Notes the steps [playerId] (the human by default) has reached in
  /// [game] by the end of turn [turn].
  void observe(Game game, int turn, {String? playerId}) {
    final String id = playerId ?? game.humanPlayerId;
    final Set<TransitionBaseType> held = game.capturedBaseTypesOf(id);
    if (held.contains(TransitionBaseType.faille)) failleCaptured ??= turn;
    if (held.contains(TransitionBaseType.cheminee)) chemineeCaptured ??= turn;
    if (game.isVolcanicKernelCapturedBy(id)) {
      kernelCaptured ??= turn;
    }
  }

  /// Notes the kraken wave of [report], if a turn ended on one.
  void observeWave(VolcanoReport? report) {
    if (report != null) waves.add(ScriptRaid.ofWave(report));
  }

  /// Notes the guardians' strike [report], if a turn ended on one.
  void observeLeviathan(FactionAttackReport? report) {
    if (report == null) return;
    leviathanStruck = report.entry.turn;
    leviathanHeld = report.outcome == AttackOutcome.repelled;
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'failleCaptured': failleCaptured,
        'chemineeCaptured': chemineeCaptured,
        'kernelCaptured': kernelCaptured,
        'leviathanStruck': leviathanStruck,
        'leviathanHeld': leviathanHeld,
        'raids': raids.map((ScriptRaid r) => r.toJson()).toList(),
        'waves': waves.map((ScriptRaid r) => r.toJson()).toList(),
      };
}

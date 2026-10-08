import '../game/game.dart';
import '../map/transition_base_type.dart';
import '../raid/raid_report.dart';

/// One raid of a scripted game, as the turn summary showed it.
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
        monsters: report.wave.unitCount,
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

/// First turn each step of the road to the volcano was reached, and every
/// raid of the game.
class ScriptMilestones {
  int? failleCaptured;
  int? chemineeCaptured;
  int? kernelCaptured;
  final List<ScriptRaid> raids = <ScriptRaid>[];

  ScriptMilestones();

  /// Notes the steps [game] has reached by the end of turn [turn].
  void observe(Game game, int turn) {
    final Set<TransitionBaseType> held =
        game.capturedBaseTypesOf(game.humanPlayerId);
    if (held.contains(TransitionBaseType.faille)) failleCaptured ??= turn;
    if (held.contains(TransitionBaseType.cheminee)) chemineeCaptured ??= turn;
    if (game.isVolcanicKernelCapturedBy(game.humanPlayerId)) {
      kernelCaptured ??= turn;
    }
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'failleCaptured': failleCaptured,
        'chemineeCaptured': chemineeCaptured,
        'kernelCaptured': kernelCaptured,
        'raids': raids.map((ScriptRaid r) => r.toJson()).toList(),
      };
}

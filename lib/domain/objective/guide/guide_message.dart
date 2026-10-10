import '../objective_id.dart';

/// What the guide of the tutorial, the octopus archivist, says: one lesson
/// per objective of the tutorial, then a word for each situation that
/// holds an objective back. The presentation words it from its figures.
sealed class GuideMessage {
  const GuideMessage();

  /// The figures the message carries, which tell two messages apart.
  List<Object> get _figures => const [];

  @override
  bool operator ==(Object other) =>
      other is GuideMessage &&
      other.runtimeType == runtimeType &&
      _sameFigures(other._figures);

  bool _sameFigures(List<Object> others) {
    final mine = _figures;
    if (mine.length != others.length) return false;
    for (var i = 0; i < mine.length; i++) {
      if (mine[i] != others[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(runtimeType, Object.hashAll(_figures));

  @override
  String toString() => '$runtimeType$_figures';
}

/// The lesson of the tutorial objective [objective].
class GuideLesson extends GuideMessage {
  final ObjectiveId objective;

  const GuideLesson(this.objective);

  @override
  List<Object> get _figures => [objective];
}

/// The objective is met: end the turn to validate it.
class GuideGoalMet extends GuideMessage {
  const GuideGoalMet();
}

/// The building site of the turn is taken.
class GuideWorksiteTaken extends GuideMessage {
  const GuideWorksiteTaken();
}

/// The units asked for were already recruited this turn.
class GuideAlreadyRecruited extends GuideMessage {
  const GuideAlreadyRecruited();
}

/// A scout is on its way.
class GuideExploring extends GuideMessage {
  const GuideExploring();
}

/// A storm closes the exploration until the end of [untilTurn].
class GuideStorm extends GuideMessage {
  final int untilTurn;

  const GuideStorm(this.untilTurn);

  @override
  List<Object> get _figures => [untilTurn];
}

/// A wreck lies on the map until the end of [untilTurn], out of reach:
/// with no barracks yet ([hasBarracks] false), or with no scout.
class GuideWreck extends GuideMessage {
  final int untilTurn;
  final bool hasBarracks;

  const GuideWreck(this.untilTurn, {required this.hasBarracks});

  @override
  List<Object> get _figures => [untilTurn, hasBarracks];
}

/// The first raid, of [monsters] monsters, announced for the end of
/// [arrivalTurn]: how many Harpoonists stand against it on the base level.
class GuideRaidAlert extends GuideMessage {
  final int arrivalTurn;
  final int monsters;

  /// Harpoonists the base level needs to push it back, `null` when no
  /// number of them would.
  final int? needed;

  /// Harpoonists still to recruit, 0 once the base should hold.
  final int missing;

  /// Whether they can be recruited this turn.
  final bool canRecruit;

  /// Whether the raid strikes at the end of this turn.
  final bool lastTurn;

  const GuideRaidAlert(
    this.arrivalTurn,
    this.monsters, {
    this.needed,
    this.missing = 0,
    this.canRecruit = false,
    this.lastTurn = false,
  });

  @override
  List<Object> get _figures => [
    arrivalTurn,
    monsters,
    needed ?? -1,
    missing,
    canRecruit,
    lastTurn,
  ];
}

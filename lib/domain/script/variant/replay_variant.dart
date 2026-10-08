/// How a variant of an exported replay departs from the original game.
///
/// The default variant plays the human's plan again on the same map with
/// the same dice; each field moves one thing away from it, to measure how
/// much the win owed to that thing.
class ReplayVariant {
  /// Plays on the replay's map; otherwise each seed draws a new map and
  /// the map actions (explore, collect, attack...) aim at what the player
  /// has revealed there instead of the original cells.
  final bool sameMap;

  /// Rolls the replay's dice (fights, loot, raids); otherwise the
  /// runner's seed rolls them.
  final bool sameDice;

  /// Factor applied to every recruit of fighters; selections of units
  /// are then cut to what is there.
  final double army;

  /// Each turn of the plan is played up to this many turns late, drawn at
  /// random for each turn.
  final int jitter;

  /// Turn `t` of the plan is played at turn `t × stretch`, as by a slower
  /// player.
  final double stretch;

  /// Recruits what the base needs whenever a raid is announced, as the
  /// careful strategy does, before playing the plan; without it, only
  /// the plan's own recruits defend.
  final bool defends;

  /// Turns a step that fails is tried again before it is given up.
  final int patience;

  const ReplayVariant({
    this.sameMap = true,
    this.sameDice = true,
    this.army = 1,
    this.jitter = 0,
    this.stretch = 1,
    this.patience = 6,
    this.defends = false,
  });

  /// Whether this variant replays the original game exactly.
  bool get isExact =>
      sameMap &&
      sameDice &&
      army == 1 &&
      jitter == 0 &&
      stretch == 1 &&
      !defends;

  /// Short label for reports, such as `carte+dés, armée ×0.8, retard 2`.
  String get label => <String>[
    sameMap ? 'même carte' : 'autre carte',
    sameDice ? 'mêmes dés' : 'autres dés',
    if (army != 1) 'armée ×$army',
    if (jitter > 0) 'retard 0-$jitter',
    if (stretch != 1) 'tempo ×$stretch',
    if (defends) 'défense prudente',
  ].join(', ');
}

/// Shape of every research branch: odd levels are tiers shared by all
/// players, even levels are a choice between two exclusive options.
abstract final class TechTree {
  static const int maxLevel = 5;

  /// Levels holding a choice between two options (2 and 4).
  static bool isChoiceLevel(int level) =>
      level > 0 && level < maxLevel && level.isEven;

  /// Position of the choice node of [level] among a branch's choices.
  static int choiceIndex(int level) => level ~/ 2 - 1;

  /// Tiers (levels 1, 3 and 5) completed once [researchLevel] is reached.
  static int tiersReached(int researchLevel) => (researchLevel + 1) ~/ 2;
}

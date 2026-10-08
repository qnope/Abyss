/// How many building upgrades and research nodes a turn allows.
class WorksiteRules {
  /// Headquarters levels that open one more building site each.
  static const List<int> extraSiteAtHq = <int>[5, 10];

  /// Research nodes the laboratory runs each turn.
  static const int researchPerTurn = 1;

  /// Building upgrades allowed each turn with the headquarters at
  /// [hqLevel]: one, plus one per level of [extraSiteAtHq] reached.
  static int buildSites(int hqLevel) =>
      1 + extraSiteAtHq.where((int level) => hqLevel >= level).length;

  /// Headquarters level that opens the next building site, or `null`
  /// once every site is open.
  static int? nextSiteAtHq(int hqLevel) {
    for (final int level in extraSiteAtHq) {
      if (hqLevel < level) return level;
    }
    return null;
  }
}

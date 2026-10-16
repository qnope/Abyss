/// Counts what each player did in a replay journal: the decoded actions
/// of each turn (`ReplayJournal.actionsOf`, or the `turns` of an exported
/// replay). A move without `player` key is the human's (`human`).
class FactionTally {
  /// Counters per player id, by name such as `upgrade`, `explore@3`,
  /// `collect@2`, `attackPlayer`, `unlock:explorer`, `research:military`.
  final Map<String, Map<String, int>> counts = <String, Map<String, int>>{};

  /// Level of the held kernel when the factions of a turn played (0 or
  /// absent: nobody held it); filled by whoever watches the game.
  final Map<int, int> kernelLevelAt = <int, int>{};

  /// Faction attacks on a held kernel, by the level the kernel stood at
  /// that turn (the human's own attacks are left out).
  final Map<int, int> heldKernelByLevel = <int, int>{};

  static const Set<String> _leveled = <String>{'explore', 'collect'};
  static const Set<String> _branched = <String>{'unlock', 'research'};

  void bump(String who, String key, [int by = 1]) {
    final Map<String, int> c = counts[who] ??= <String, int>{};
    c[key] = (c[key] ?? 0) + by;
  }

  int of(String who, String key) => counts[who]?[key] ?? 0;

  /// The counted players other than the human, sorted.
  List<String> get factionIds =>
      counts.keys.where((String who) => who != 'human').toList()..sort();

  /// Notes that [who] took part in [turns] more turns (a faction drawn in
  /// only some games of a batch counts only those).
  void played(String who, int turns) => bump(who, 'turns', turns);

  /// [key] per turn [who] took part in (0 if it never played).
  double perTurn(String who, String key) {
    final int turns = of(who, 'turns');
    return turns == 0 ? 0 : of(who, key) / turns;
  }

  /// [key] per turn of a faction, over all [factionIds] (0 without any).
  double factionMean(String key) {
    int n = 0, turns = 0;
    for (final String who in factionIds) {
      n += of(who, key);
      turns += of(who, 'turns');
    }
    return turns == 0 ? 0 : n / turns;
  }

  /// Adds the moves of each `(turn, moves)` of [journal].
  void addJournal(Iterable<(int, List<Map<String, Object?>>)> journal) {
    for (final (int turn, List<Map<String, Object?>> moves) in journal) {
      for (final Map<String, Object?> m in moves) {
        _add(m, kernelLevelAt[turn] ?? 0);
      }
    }
  }

  void _add(Map<String, Object?> m, int kernelLevel) {
    final String who = m['player'] as String? ?? 'human';
    final String verb = m['do']! as String;
    bump(who, verb);
    if (_leveled.contains(verb)) bump(who, '$verb@${m['level'] ?? 1}');
    if (_branched.contains(verb)) bump(who, '$verb:${m['branch']}');
    if (verb == 'attackPlayer' && m['target'] == 'human') {
      bump(who, 'attackHuman');
    }
    if (verb == 'attackHeldKernel' && who != 'human') {
      heldKernelByLevel[kernelLevel] =
          (heldKernelByLevel[kernelLevel] ?? 0) + 1;
    }
  }

  /// Adds the counters of [other], to sum a batch.
  void merge(FactionTally other) {
    other.counts.forEach(
      (String who, Map<String, int> c) => c.forEach((k, v) => bump(who, k, v)),
    );
    other.heldKernelByLevel.forEach(
      (int l, int n) => heldKernelByLevel[l] = (heldKernelByLevel[l] ?? 0) + n,
    );
  }
}

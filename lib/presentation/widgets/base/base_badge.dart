/// What floats over a building of the base, or a squad of the army, to
/// tell what it needs.
enum BaseBadge {
  /// A green chevron: it can go up a level right now.
  upgrade,

  /// An orange triangle: a headquarters too low degrades it.
  warning,

  /// A green plus: a squad of the army can recruit right now.
  recruit,
}

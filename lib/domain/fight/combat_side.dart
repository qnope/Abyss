enum CombatSide { player, monster }

extension CombatSideX on CombatSide {
  CombatSide get opponent {
    switch (this) {
      case CombatSide.player:
        return CombatSide.monster;
      case CombatSide.monster:
        return CombatSide.player;
    }
  }
}

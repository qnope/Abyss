class FightTurnSummary {
  final int turnNumber;
  final int attacksPlayed;
  final int critCount;
  final int damageDealtByPlayer;
  final int damageDealtByMonster;
  final int playerAliveAtEnd;
  final int monsterAliveAtEnd;
  final int playerHpAtEnd;
  final int monsterHpAtEnd;

  const FightTurnSummary(
    this.turnNumber,
    this.attacksPlayed,
    this.critCount,
    this.damageDealtByPlayer,
    this.damageDealtByMonster,
    this.playerAliveAtEnd,
    this.monsterAliveAtEnd,
    this.playerHpAtEnd,
    this.monsterHpAtEnd,
  );
}

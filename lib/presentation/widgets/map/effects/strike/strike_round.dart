import '../../../../../domain/fight/fight_result.dart';

/// One turn of a fight played on the map: what the player's side dealt
/// to the other and what it took from it, in hit points.
typedef StrikeRound = ({int dealt, int taken});

/// The rounds of [fight], one per turn; none without a fight.
List<StrikeRound> roundsOf(FightResult? fight) => [
      for (final turn in fight?.turnSummaries ?? const [])
        (dealt: turn.damageDealtByPlayer, taken: turn.damageDealtByMonster),
    ];

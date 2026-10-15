import '../../../../../domain/fight/fight_result.dart';

/// One turn of a fight played on the map: what the player's side dealt
/// to the other and what it took from it, in hit points.
typedef StrikeRound = ({int dealt, int taken});

/// The rounds of [fight], one per turn; none without a fight.
List<StrikeRound> roundsOf(FightResult? fight) => [
      for (final turn in fight?.turnSummaries ?? const [])
        (dealt: turn.damageDealtByPlayer, taken: turn.damageDealtByMonster),
    ];

/// The rounds of [fight] seen from the side attacked, which the engine
/// sets on its monster side (a base, a post or a kernel defending against
/// a faction): what the defenders dealt, and what they took.
List<StrikeRound> defenceRoundsOf(FightResult? fight) => [
      for (final (:dealt, :taken) in roundsOf(fight))
        (dealt: taken, taken: dealt),
    ];

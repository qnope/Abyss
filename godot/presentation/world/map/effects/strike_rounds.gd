class_name StrikeRounds
extends RefCounted
## The rounds of a fight played on the map (lib/presentation/widgets/map/
## effects/strike/strike_round.dart): one per turn, a Vector2i of what the
## player's side dealt to the other (x) and what it took from it (y), in hit
## points.


## The rounds of [param fight], one per turn; none without a fight.
static func of(fight: FightResult) -> Array[Vector2i]:
	var rounds: Array[Vector2i] = []
	if fight == null:
		return rounds
	for turn in fight.turn_summaries:
		rounds.append(Vector2i(turn.damage_dealt_by_player, turn.damage_dealt_by_monster))
	return rounds


## The rounds of [param fight] seen from the side attacked, which the engine
## sets on its monster side (a base, a post or a kernel defending against a
## faction): what the defenders dealt (x), and what they took (y).
static func defence_of(fight: FightResult) -> Array[Vector2i]:
	var rounds: Array[Vector2i] = []
	for round_ in of(fight):
		rounds.append(Vector2i(round_.y, round_.x))
	return rounds

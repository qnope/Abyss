class_name DefeatChecker
extends RefCounted
## lib/domain/game/defeat_checker.dart: ends the game once the base has lost
## too many raids in a row.

## Raids lost in a row that make the base fall.
const LOST_RAIDS_LIMIT := 3


## GameStatus.Value.DEFEAT when the human player has just lost, null when
## nothing changes. Only a game still being played can be lost.
static func check(game: Game) -> Variant:
	if game.status != GameStatus.Value.PLAYING:
		return null
	var lost := game.human_player().raid_state.lost_in_a_row
	return GameStatus.Value.DEFEAT if lost >= LOST_RAIDS_LIMIT else null


## Whether losing the next raid ends the game.
static func is_last_chance(game: Game) -> bool:
	return (
		game.status == GameStatus.Value.PLAYING
		and game.human_player().raid_state.lost_in_a_row >= LOST_RAIDS_LIMIT - 1
	)

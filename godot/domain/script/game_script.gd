@abstract
class_name GameScript
extends RefCounted
## lib/domain/script/game_script.dart: a way to play a whole game without
## the UI.
##
## Each turn, `ScriptRunner` hands the script a ScriptTurn to act on through
## the regular action system, then ends the turn itself. Dart's getters are
## methods; those that may answer `null` return a Variant.


## Name shown in reports.
@abstract func name() -> String


## Plays the current turn. Ending the turn is left to the runner.
@abstract func play_turn(turn: ScriptTurn) -> void


## Name of the player; a replay keeps the one of the exported game.
func player_name() -> String:
	return name()


## Seed of the first level (an int); null lets the runner's seed pick it.
func map_seed() -> Variant:
	return null


## Difficulty the game was played in (a Difficulty.Value); null lets the
## runner pick it.
func difficulty() -> Variant:
	return null


## Factions the game is played against, in the order they play; none by
## default, a replay names those of the exported game.
func factions() -> Array[FactionPersonality.Value]:
	return []


## Whether the factions' brains play at the end of each turn. A replay says
## no: the actions of the factions are already in its timeline.
func factions_play() -> bool:
	return true


## The turn the game stops on, before ending it (an int); null plays on.
func last_turn() -> Variant:
	return null


## Generator for the end of `turn` (raids); null uses the runner's.
func end_turn_random(_turn: int) -> DartRandom:
	return null

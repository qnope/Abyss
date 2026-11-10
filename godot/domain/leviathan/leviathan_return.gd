class_name LeviathanReturn
extends RefCounted
## lib/domain/leviathan/leviathan_return.dart: bookkeeping of "the Léviathan
## comes back": once per game, the guardians of the first Faille the human
## takes strike back DELAY turns after the capture, or after its Module de
## descente first works, whichever is later: nobody can defend the Faille
## before.
##
## Only the human gets it. A game keeps one from its start.

## Turns between the capture (or the Module working) and the end of the
## turn the guardians strike; the end of the turn before announces them.
const DELAY := 3

## Code of the Faille the guardians come back to (a String), or null.
var post_name: Variant
## Level of the map the Faille stands on (an int), or null.
var level: Variant
## Cell of the Faille on its level.
var at: GridPosition
## Earliest turn at the end of which the guardians strike (an int), DELAY
## turns after the capture; null until the first Faille is taken.
var strike_turn: Variant
## Whether it is over: fought, or cancelled with the Faille lost.
var over: bool
## Turn the Module de descente was first seen working while the Faille was
## held (an int); null until then.
var ready_turn: Variant


func _init(
	post_name_: Variant = null,
	level_: Variant = null,
	at_: GridPosition = null,
	strike_turn_: Variant = null,
	over_ := false,
	ready_turn_: Variant = null,
) -> void:
	post_name = post_name_
	level = level_
	at = at_
	strike_turn = strike_turn_
	over = over_
	ready_turn = ready_turn_


## Whether no Faille scheduled it yet in this game.
func is_available() -> bool:
	return strike_turn == null


## Whether the guardians are still to come.
func is_scheduled() -> bool:
	return strike_turn != null and not over


## Turn at the end of which the guardians strike (an int): DELAY turns
## after the capture or after `ready_turn`, the later; null while the
## Module has not worked yet, the strike postponed.
func due_turn() -> Variant:
	if strike_turn == null or ready_turn == null:
		return null
	var earliest: int = strike_turn
	var ready: int = ready_turn
	return maxi(earliest, ready + DELAY)


## The Module de descente works during `turn`: the first time sets the
## strike.
func mark_ready(turn: int) -> void:
	if ready_turn == null:
		ready_turn = turn


## The Faille `post_name_` at `at_` on `level_` was taken during
## `captured_on`: the guardians strike DELAY turns later.
func schedule(post_name_: String, level_: int, at_: GridPosition, captured_on: int) -> void:
	post_name = post_name_
	level = level_
	at = at_
	strike_turn = captured_on + DELAY


## Ends it for good: it never comes back.
func end() -> void:
	over = true

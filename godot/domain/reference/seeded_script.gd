class_name SeededScript
extends GameScript
## lib/domain/reference/seeded_script.dart: plays `inner` with dice the
## journal can write down: every action that rolls dice gets a freshly
## seeded generator of its own, and so does every end of turn, the way the
## game screen plays. The journal of the game is then exact: replaying it
## plays the very same game.
##
## The seeds come from one generator, `Random(seed)`, drawn in the order
## the strategy asks for dice, then one per end of turn. A turn of the human
## is played as a FactionTurn, which is that very way of rolling.

var inner: GameScript
var _executor: ActionExecutor
var _seeds: DartRandom


func _init(inner_: GameScript, seed_: int, executor: ActionExecutor) -> void:
	inner = inner_
	_executor = executor
	_seeds = DartRandom.new(seed_, false)


func name() -> String:
	return inner.name()


func player_name() -> String:
	return inner.player_name()


func map_seed() -> Variant:
	return inner.map_seed()


func difficulty() -> Variant:
	return inner.difficulty()


func factions() -> Array[FactionPersonality.Value]:
	return inner.factions()


func factions_play() -> bool:
	return inner.factions_play()


func last_turn() -> Variant:
	return inner.last_turn()


func play_turn(turn: ScriptTurn) -> void:
	inner.play_turn(FactionTurn.new(turn.game, turn.player, _executor, _seeds))


## The seed a replay recorded for the end of `turn`, or a fresh one.
func end_turn_random(turn: int) -> DartRandom:
	var recorded := inner.end_turn_random(turn)
	return recorded if recorded != null else DartRandom.new(_seeds.next_int(0x7FFFFFFF))

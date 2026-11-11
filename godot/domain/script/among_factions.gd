class_name AmongFactions
extends GameScript
## lib/domain/script/among_factions.dart: a script played in a world with
## factions: the same moves as `inner`, with `factions` racing it to the
## volcano.

var inner: GameScript

var _factions: Array[FactionPersonality.Value]


func _init(inner_: GameScript, factions_: Array[FactionPersonality.Value]) -> void:
	inner = inner_
	_factions = factions_


## `AmongFactions.drawn`: `count` factions drawn from the catalogue with
## `seed_`.
static func drawn(inner_: GameScript, count: int, seed_ := 0) -> AmongFactions:
	var drawn_factions: Array[FactionPersonality.Value] = []
	if count != 0:
		drawn_factions = FactionCatalogue.draw(count, seed_)
	return AmongFactions.new(inner_, drawn_factions)


func factions() -> Array[FactionPersonality.Value]:
	return _factions


func name() -> String:
	return "%s+%d" % [inner.name(), _factions.size()]


func play_turn(turn: ScriptTurn) -> void:
	inner.play_turn(turn)


func player_name() -> String:
	return inner.player_name()


func map_seed() -> Variant:
	return inner.map_seed()


func difficulty() -> Variant:
	return inner.difficulty()


func factions_play() -> bool:
	return inner.factions_play()


func last_turn() -> Variant:
	return inner.last_turn()


func end_turn_random(turn: int) -> DartRandom:
	return inner.end_turn_random(turn)

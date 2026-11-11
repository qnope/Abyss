class_name TimelineScript
extends GameScript
## lib/domain/script/timeline_script.dart: a scenario written in advance,
## the actions to play on given turns.
##
## Turns the timeline leaves out are handed to `otherwise` when set, so a
## scenario can force a few moves and let a strategy play the rest.
##
## An exported replay also pins the map, the player, the dice of every end
## of turn and the turn to stop on, so it plays the original game again.
## An action may name another player: it is played as that player, in
## order, and no strategy is ever asked for it.
##
## An ActionSpec is a Callable taking the turn's DartRandom and giving the
## Action (ActionCodec.decode). The getters of GameScript are methods, so
## the fields that back them are private.

## The specs of each turn, an Array of Callables by turn.
var turns: Dictionary[int, Array]
var otherwise: GameScript
## The name of the player (a String), or null for the script's name.
var player: Variant
var end_turn_seeds: Dictionary[int, int]
## Who plays each action of `turns`, by turn and position: an Array of
## player ids or nulls; null, or no entry, is the player the script runs
## for.
var actors: Dictionary[int, Array]

var _name: String
var _map_seed: Variant
var _difficulty: Variant
var _last_turn: Variant
var _factions: Array[FactionPersonality.Value]


func _init(
	name_: String, turns_: Dictionary[int, Array], otherwise_: GameScript = null,
	player_: Variant = null, map_seed_: Variant = null, difficulty_: Variant = null,
	last_turn_: Variant = null, factions_: Array[FactionPersonality.Value] = [],
	end_turn_seeds_: Dictionary[int, int] = {}, actors_: Dictionary[int, Array] = {},
) -> void:
	_name = name_
	turns = turns_
	otherwise = otherwise_
	player = player_
	_map_seed = map_seed_
	_difficulty = difficulty_
	_last_turn = last_turn_
	_factions = factions_
	end_turn_seeds = end_turn_seeds_
	actors = actors_


func name() -> String:
	return _name


func player_name() -> String:
	return player if player != null else _name


func map_seed() -> Variant:
	return _map_seed


func difficulty() -> Variant:
	return _difficulty


func last_turn() -> Variant:
	return _last_turn


func factions() -> Array[FactionPersonality.Value]:
	return _factions


## A timeline holds every move of every player, so no brain plays.
func factions_play() -> bool:
	return false


func end_turn_random(turn: int) -> DartRandom:
	return DartRandom.new(end_turn_seeds[turn]) if end_turn_seeds.has(turn) else null


## Where Dart throws on a player the game does not hold, logs an error and
## leaves the action out.
func play_turn(turn: ScriptTurn) -> void:
	if not turns.has(turn.number()):
		if otherwise != null:
			otherwise.play_turn(turn)
		return
	var planned: Array = turns[turn.number()]
	var ids: Array = actors.get(turn.number(), [])
	for i: int in planned.size():
		var id: Variant = ids[i] if i < ids.size() else null
		var actor := _turn_of(turn, id)
		if actor != null:
			var spec: Callable = planned[i]
			var action: Action = spec.call(turn.random())
			actor.perform(action)


func _turn_of(turn: ScriptTurn, id: Variant) -> ScriptTurn:
	if id == null:
		return turn
	if not turn.game.players.has(id):
		push_error("Joueur inconnu dans le scénario : %s" % id)
		return null
	return turn.as_player(turn.game.players[id])

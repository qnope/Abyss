class_name ReferenceRecorder
extends GameCapture
## lib/domain/reference/reference_recorder.dart: an executor that records
## the state of the game it plays: the digests of every section at the
## start of turn 1 then after each end of turn, what it executed, and on
## request the whole state at the start of one turn (`dump_turn`) and the
## digests after each action of one turn (`trace_turn`).
##
## It sees an action only when it executes it: in a replay every move of
## every player, in a live game not those the factions play inside the end
## of a turn. Its record `TurnDigests` is ReplayComparison.Turn.

## Takes a text and gives its digest (Sha256Hex.of).
var digest: Callable
## The turns traced and dumped, ints or null.
var trace_turn: Variant
var dump_turn: Variant

var turns: Array[ReplayComparison.Turn] = []
## Successful actions, the ends of turn included, by type.
var actions: Dictionary[ActionType.Value, int] = {}
## Random events drawn, for any player, by type.
var events: Dictionary[RandomEventType.Value, int] = {}
## The digests after each action of `trace_turn`, in order.
var traced: Array[PackedStringArray] = []
## The canonical texts at the start of `dump_turn` once reached (a
## Dictionary[String, String]), null before.
var dump: Variant = null


func _init(digest_: Callable, trace_turn_: Variant = null, dump_turn_: Variant = null) -> void:
	digest = digest_
	trace_turn = trace_turn_
	dump_turn = dump_turn_


func on_start(game_: Game) -> void:
	_start_turn(game_)


func execute(action: Action, game_: Game, player: Player) -> ActionResult:
	var turn := game_.turn
	var seen := _events_seen(game_)
	var result := super.execute(action, game_, player)
	if not result.is_success:
		return result
	actions[action.type()] = actions.get(action.type(), 0) + 1
	if action is EndTurnAction:
		_count_events(game_, seen)
		_start_turn(game_)
	elif turn == trace_turn:
		traced.append(GameSnapshot.digests(game_, digest))
	return result


func _start_turn(game_: Game) -> void:
	var texts := GameSnapshot.texts(game_)
	if game_.turn == dump_turn:
		dump = texts
	var digests := PackedStringArray()
	for text: String in texts.values():
		var hex: String = digest.call(text)
		digests.append(hex)
	turns.append(ReplayComparison.Turn.new(game_.turn, digests))


static func _events_seen(game_: Game) -> Dictionary[String, int]:
	var seen: Dictionary[String, int] = {}
	for p: Player in game_.players.values():
		seen[p.id] = p.event_state.events_seen
	return seen


func _count_events(game_: Game, before: Dictionary[String, int]) -> void:
	for p: Player in game_.players.values():
		if p.event_state.events_seen == before.get(p.id):
			continue
		var drawn: RandomEventType.Value = p.event_state.last_drawn
		events[drawn] = events.get(drawn, 0) + 1

class_name EventMoveSamples
extends RefCounted
## The GDScript twin of test/domain/script/strategies/
## event_moves_test_helper.dart: the turns the tests of EventMoves play and
## the choice they read back.


## `scriptTurnOf`: a script turn of the single-player `game` of its human.
static func script_turn_of(game: Game) -> ScriptTurn:
	return ScriptSamples.turn(game)


## `choiceTurn`: script turn 12 of `player`, who waits for a choice on
## `type` drawn at the end of turn 11. No other draw is scheduled.
static func choice_turn(player: Player, type: RandomEventType.Value) -> ScriptTurn:
	player.event_state.schedule(100)
	player.event_state.set_pending(type, 12)
	var game := Game.single_player(player)
	game.turn = 12
	return script_turn_of(game)


## `choiceOf`: the choice `player` made on the turn's event, true for the
## first option, false for the prudent one, null when none was made yet.
static func choice_of(player: Player) -> Variant:
	var entries := EventSamples.event_entries_of(player)
	if entries.is_empty():
		return null
	if entries.size() != 1:
		push_error("choice_of: %d event entries, one expected" % entries.size())
	var entry := entries[0]
	return null if entry.defaulted else entry.accepted

class_name WreckNotice
extends RefCounted
## « Épave : encore 3 tours » (lib/presentation/extensions/
## event_state_extensions.dart: `wreckCountdownAt`): how long the wreck lying at
## a cell can still be searched, in the language on.


## The countdown when the wreck of the human player lies at ([param x],
## [param y]) on [param level], "" when it lies elsewhere or nowhere. The
## current turn counts, and the wreck can be searched through the last one.
static func at(game: Game, x: int, y: int, level: int) -> String:
	var state := game.human_player().event_state
	var site := state.wreck_position
	if site == null or state.wreck_until_turn == null or level != WreckSites.LEVEL:
		return ""
	if site.x != x or site.y != y:
		return ""
	var until: int = state.wreck_until_turn
	return Texts.t(&"eventCountdown", {
		"label": Texts.t(&"randomEventWreckLabel"), "turns": until - game.turn + 1,
	})

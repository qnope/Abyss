class_name TurnWarnings
extends RefCounted
## The warnings under the figures of the end-of-turn confirmation, in order
## (lib/presentation/screens/game/game_screen_turn_helpers.dart: dueWarnings).
## Each is a Control, or nothing when there is nothing to say; a lot that owns
## a warning adds a line to [method of]. The threats come first, as in Flutter
## ([ThreatWarnings]: the raid, the predators, the guardians of a Faille, the
## kraken wave), then the posts nobody defends, then the event still waiting
## for a choice ([EventPendingWarning]).


## The warnings that apply to [param player] in [param game], in order.
static func of(game: Game, player: Player) -> Array[Control]:
	var found := ThreatWarnings.of(game, player)
	var undefended := UndefendedPosts.of(game, player)
	if not undefended.is_empty():
		found.append(UndefendedPostWarning.new(undefended))
	if player.event_state.has_pending():
		var pending: RandomEventType.Value = player.event_state.pending
		found.append(EventPendingWarning.new(pending))
	return found

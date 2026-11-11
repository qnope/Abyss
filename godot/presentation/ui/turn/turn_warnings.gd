class_name TurnWarnings
extends RefCounted
## The warnings under the figures of the end-of-turn confirmation, in order
## (lib/presentation/screens/game/game_screen_turn_helpers.dart: dueWarnings).
## Each is a Control, or nothing when there is nothing to say; a lot that owns
## a warning adds a line to [method of]:
##
## - to come: the raid and the school of predators due (lot 11), the guardians
##   of a Faille and the kraken wave on the kernel (lots 11 and 12), the event
##   still waiting for a choice (lot 14).


## The warnings that apply to [param player] in [param game], in order.
static func of(game: Game, player: Player) -> Array[Control]:
	var found: Array[Control] = []
	var undefended := UndefendedPosts.of(game, player)
	if not undefended.is_empty():
		found.append(UndefendedPostWarning.new(undefended))
	return found

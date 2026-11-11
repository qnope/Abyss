class_name MapStates
extends RefCounted
## What the map of a level shows, read from the game (the arguments `buildMapTab`
## gives `GameMapView`, lib/presentation/screens/game/game_screen_map_actions.dart):
## the cells seen, the player's base on the first level, the scouts on their
## way, the rival bases with the colour of their faction, the colour of whoever
## can hold the volcano and who holds the post above each passage. The colours
## are the interface's, so `app/` gives them to the world, which has none.


## The state of [param level] of [param game].
static func of(game: Game, level: int) -> MapLevelState:
	var human := game.human_player()
	var revealed := human.revealed_cells_set_on_level(level)
	var state := MapLevelState.new(level, game.levels[level], human.id, revealed)
	if level == 1:
		state.base = Vector2i(human.base_x, human.base_y)
		state.faction_bases = _faction_bases(game)
	state.owner_colors = _owners(game)
	var above: GameMap = game.levels.get(level - 1)
	state.passage_holders = PostHolder.passages_below(above, human.id)
	for order in human.pending_explorations:
		if order.level == level:
			var target := order.target.key()
			state.pending[target] = ScoutOrigin.of(target, state.base, state.passage_holders, revealed)
	return state


## The colour of each faction base of the first level, by cell.
static func _faction_bases(game: Game) -> Dictionary[Vector2i, Color]:
	var bases: Dictionary[Vector2i, Color] = {}
	for faction in game.factions():
		var player: Player = game.players.get(faction.id())
		if player != null:
			bases[Vector2i(player.base_x, player.base_y)] = FactionColors.of(faction.personality)
	return bases


## The seal colour of each player who can hold the volcano: the human in the
## cyan of their base, each faction in its own colour.
static func _owners(game: Game) -> Dictionary[String, Color]:
	var owners: Dictionary[String, Color] = {game.human_player_id: AbyssColors.BIOLUM_CYAN}
	for faction in game.factions():
		owners[faction.id()] = FactionColors.of(faction.personality)
	return owners

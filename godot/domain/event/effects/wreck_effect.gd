class_name WreckEffect
extends EventEffect
## lib/domain/event/effects/wreck_effect.dart: a wreck sunk at the draw on a
## hidden cell at the edge of the explored area (see WreckSites). It has no
## choice: the player explores it with a scout then searches it like ruins,
## or lets it sink out of reach after WRECK_TURNS turns. The end of the turn
## tells which (see settle).


## Only when a site is free and no other wreck lies on the map.
func allowed_at(game: Game, player: Player, _ended_turn: int) -> bool:
	var map: GameMap = game.levels.get(WreckSites.LEVEL)
	return (
		player.event_state.wreck_position == null
		and map != null
		and not WreckSites.of(map, player).is_empty()
	)


## Sinks the wreck on a site picked with the dice of the draw, to be
## searched through the end of turn `turn` + WRECK_TURNS.
func on_draw(game: Game, player: Player, turn: int, random: DartRandom) -> void:
	var map: GameMap = game.levels.get(WreckSites.LEVEL)
	if map == null:
		return
	var sites := WreckSites.of(map, player)
	if sites.is_empty():
		return
	var at := sites[random.next_int(sites.size())]
	_set_content(map, at, CellContentType.Value.WRECK)
	player.event_state.wreck_position = at
	player.event_state.wreck_until_turn = turn + EventRules.WRECK_TURNS


## Forgets, at the end of `turn`, the wreck searched during it, or the one
## left unsearched once its last turn is over: it sinks and its cell is
## empty again. Returns how it left, null while it still lies.
static func settle(game: Game, player: Player, turn: int) -> WreckEnding:
	var state := player.event_state
	if state.wreck_until_turn == null:
		return null
	var until: int = state.wreck_until_turn
	if state.wreck_searched():
		state.clear_wreck()
		return WreckEnding.new(true, until)
	var at := state.wreck_position
	if at == null or turn < until:
		return null
	var map: GameMap = game.levels.get(WreckSites.LEVEL)
	var cell: MapCell = map.cell_at(at.x, at.y) if map != null else null
	if cell != null and cell.content == CellContentType.Value.WRECK and not cell.is_collected():
		_set_content(map, at, CellContentType.Value.EMPTY)
	state.clear_wreck()
	return WreckEnding.new(false, until)


## Takes the wreck of `player` searched at `at` off the map; it is forgotten
## at the end of the turn (see settle).
static func searched(player: Player, at: GridPosition) -> void:
	var state := player.event_state
	if at.equals(state.wreck_position):
		state.wreck_position = null


static func _set_content(map: GameMap, at: GridPosition, to: CellContentType.Value) -> void:
	map.set_cell(at.x, at.y, map.cell_at(at.x, at.y).copy_with({"content": to}))

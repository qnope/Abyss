class_name AssaultSamples
extends RefCounted
## The GDScript twin of test/helpers/base_attack_helper.dart: a two-player
## game where the human may strike or spy on the rival's base, and the
## helpers that set what stands on a base.

## `horde`: an army that beats a bare base.
const HORDE: Dictionary[UnitType.Value, int] = {UnitType.Value.HARPOONIST: 40}
## `wall`: a defence nobody beats.
const WALL: Dictionary[UnitType.Value, int] = {UnitType.Value.GUARDIAN: 60, UnitType.Value.HARPOONIST: 60}


## `assaultGame`: `GameSamples.two_players` at `turn`, both headquarters at
## level 5, the human having seen the rival's base when `revealed`.
static func assault_game(turn := 12, revealed := true, rival_id := "rival-1") -> Game:
	var game := GameSamples.two_players(3, rival_id)
	game.turn = turn
	for player: Player in game.players.values():
		set_level(player, BuildingType.Value.HEADQUARTERS, 5)
	if revealed:
		var rival := rival_of(game)
		game.human_player().add_revealed_cell(1, GridPosition.new(rival.base_x, rival.base_y))
	return game


## `two.rival`: the player of `game` after the human.
static func rival_of(game: Game) -> Player:
	var rival: Player = game.players.values()[1]
	return rival


## `setLevel`: a new building of `type` at `level`.
static func set_level(player: Player, type: BuildingType.Value, level: int) -> void:
	player.buildings[type] = Building.new(type, level)


## `station`: puts exactly `units` on the base level of `player`.
static func station(player: Player, units: Dictionary[UnitType.Value, int]) -> void:
	var stock := player.units_on_level(1)
	for unit: Unit in stock.values():
		unit.count = 0
	for type: UnitType.Value in units:
		stock[type].count = units[type]


## `standing`: the units of `type` on the base level of `player`.
static func standing(player: Player, type: UnitType.Value) -> int:
	return player.units_on_level(1)[type].count

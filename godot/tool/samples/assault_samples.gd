class_name AssaultSamples
extends RefCounted
## The GDScript twin of test/helpers/base_attack_helper.dart: a two-player
## game where the human may strike or spy on the rival's base, and the
## helpers that set what stands on a base; and the player of
## test/domain/fight/assault/assault_test_helper.dart.

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


## `assaultPlayer` of test/domain/fight/assault/assault_test_helper.dart:
## the player "p1" with `stock` on `level`, every building at 0 but its
## headquarters at `hq`.
static func assault_player(
	stock: Dictionary[UnitType.Value, int] = {}, level := 1, hq := 1
) -> Player:
	var buildings: Dictionary[BuildingType.Value, Building] = {}
	for type: BuildingType.Value in BuildingType.Value.values():
		buildings[type] = Building.new(type, hq if type == BuildingType.Value.HEADQUARTERS else 0)
	var units: Dictionary[UnitType.Value, Unit] = {}
	for type: UnitType.Value in UnitType.Value.values():
		var count: int = stock.get(type, 0)
		units[type] = Unit.new(type, count)
	var per_level: Dictionary[int, Dictionary] = {level: units}
	return Player.new("Test", "p1", 0, 0, null, buildings, null, per_level)


## `strike`: the human's attack on the rival's base with `army`, its dice
## `SeededRandom(seed)`.
static func strike(game: Game, army: Dictionary[UnitType.Value, int], seed_ := 1) -> AttackBaseAction:
	return AttackBaseAction.new(rival_of(game).id, army, DartRandom.new(seed_))


## `raiders` of test/helpers/announce_attack_helper.dart: the rival's army,
## strong enough to beat a bare base.
const RAIDERS: Dictionary[UnitType.Value, int] = {UnitType.Value.HARPOONIST: 40}


## `announceGame`: `assault_game` with the tutorial of the human over, the
## rival holding RAIDERS on its base.
static func announce_game(turn := 12, rival_id := "rival-1") -> Game:
	var game := assault_game(turn, true, rival_id)
	ObjectiveMigration.state_of(game, game.human_player()).tutorial_enabled = false
	station(rival_of(game), RAIDERS)
	return game


## `announce`: the rival's attack on the human with `army`, its dice
## `SeededRandom(seed)`.
static func announce(army: Dictionary[UnitType.Value, int] = RAIDERS, seed_ := 3) -> AnnounceAttackAction:
	return AnnounceAttackAction.new(army, DartRandom.new(seed_))

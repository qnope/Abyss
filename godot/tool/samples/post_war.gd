class_name PostWar
extends RefCounted
## The GDScript twin of `PostWar` of test/helpers/post_attack_helper.dart: a
## game against two factions where `owner()` holds a Faille (on level 1) or
## a Cheminée (on level 2) with its passage building, and `attacker()`
## stands ready to take it, at turn 12 with the tutorial over. With
## `human_holds`, the human is the owner.

## `horde`: an overwhelming force on the attack level.
const HORDE: Dictionary[UnitType.Value, int] = {UnitType.Value.HARPOONIST: 60}
## `wall`: a defence nobody beats.
const WALL: Dictionary[UnitType.Value, int] = {UnitType.Value.GUARDIAN: 80, UnitType.Value.HARPOONIST: 80}
## `garrison`: a few units below the post.
const GARRISON: Dictionary[UnitType.Value, int] = {UnitType.Value.HARPOONIST: 3}

var game: Game
var kind: TransitionBaseType.Value
var level: int
var at: GridPosition
var post: TransitionBase
var human_holds: bool


## `PostWar(kind, mapSeed:, humanHolds:)`: the first post of `kind` of its
## level, row by row.
func _init(kind_: TransitionBaseType.Value, map_seed := 7, human_holds_ := false) -> void:
	game = GameFactory.new_game("Nemo", map_seed, Difficulty.Value.NORMAL, false, 2)
	game.turn = 12
	kind = kind_
	human_holds = human_holds_
	level = 1 if kind == TransitionBaseType.Value.FAILLE else 2
	var map: GameMap = game.levels[level]
	for y: int in map.height:
		for x: int in map.width:
			var base := map.cell_at(x, y).transition_base
			if base != null and base.type == kind and post == null:
				at = GridPosition.new(x, y)
				post = base
	_set_up()


func attacker() -> Player:
	return game.players[game.factions()[0].id()]


func owner() -> Player:
	return game.human_player() if human_holds else game.players[game.factions()[1].id()]


func human() -> Player:
	return game.human_player()


func passage() -> BuildingType.Value:
	if kind == TransitionBaseType.Value.FAILLE:
		return BuildingType.Value.DESCENT_MODULE
	return BuildingType.Value.PRESSURE_CAPSULE


## The level whose units defend the post.
func below() -> int:
	return post.target_level()


## Puts `units` on `player`'s stock of `on_level`.
func put(player: Player, on_level: int, units: Dictionary[UnitType.Value, int]) -> void:
	for type: UnitType.Value in units:
		KernelGarrison.stock_at(player, on_level)[type].count = units[type]


func count(player: Player, on_level: int, type: UnitType.Value) -> int:
	return KernelGarrison.stock_at(player, on_level)[type].count


## `strike`: the attack on the post with `army`, its dice `SeededRandom(seed)`.
func strike(army: Dictionary[UnitType.Value, int], seed_ := 1) -> AttackPostAction:
	return AttackPostAction.new(at.x, at.y, level, army, DartRandom.new(seed_))


## The attacker's army: an overwhelming force on the attack level.
func arm(player: Player, army: Dictionary[UnitType.Value, int] = HORDE) -> void:
	put(player, level, army)


func _set_up() -> void:
	ObjectiveMigration.state_of(game, human()).tutorial_enabled = false
	post.captured_by = owner().id
	owner().buildings[passage()] = Building.new(passage(), 2)
	attacker().add_revealed_cell(level, at)
	human().add_revealed_cell(level, at)
	for p: Player in [attacker(), owner(), human()]:
		for l: int in [1, 2, 3]:
			for unit: Unit in KernelGarrison.stock_at(p, l).values():
				unit.count = 0

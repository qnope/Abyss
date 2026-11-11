extends TestCase
## Not in the Dart files (hunt_under_raid_test.dart plays ConquestStrategy):
## the raids a base holds, with or without the units sent away, and the
## lairs it clears.

const HARPOONIST := UnitType.Value.HARPOONIST
const GUARDIAN := UnitType.Value.GUARDIAN

var _planner := ArmyPlanner.new()


func _wave(count: int) -> MonsterLair:
	return MonsterLair.new(MonsterDifficulty.Value.EASY, count, MonsterFamily.Value.SWARM)


func _turn(units: Dictionary[UnitType.Value, int], citadel := 0) -> ScriptTurn:
	var player := RaidSamples.raid_player(units, citadel, 10)
	player.buildings[BuildingType.Value.BARRACKS] = Building.new(BuildingType.Value.BARRACKS, 3)
	return ScriptSamples.turn(EventSamples.event_game(player, 12))


func test_a_base_without_a_raid_holds_and_one_under_a_raid_recruits() -> void:
	var turn := _turn({})
	assert_true(BattleMoves.defend_base(turn, _planner))
	turn.player.raid_state.announce(_wave(4), 14)
	assert_false(BattleMoves.holds(turn, _wave(4), _planner))
	assert_true(BattleMoves.defend_base(turn, _planner))
	assert_true(RaidSamples.units_on_base(turn.player) > 0)
	assert_true(BattleMoves.holds(turn, _wave(4), _planner))


func test_the_rampart_of_the_citadel_backs_the_base() -> void:
	var bare := _turn({HARPOONIST: 3})
	var walled := _turn({HARPOONIST: 3}, 5)
	var wave := _wave(3)
	var rate := func(turn: ScriptTurn, allies: Callable) -> float:
		return _planner.win_rate(RaidBattle.defenders_of(turn.player), func() -> Array[Combatant]:
			return CombatantBuilder.monster_combatants_from(wave), ExpeditionMoves.defence_boost(turn), allies)
	assert_false(BattleMoves._rampart(bare).is_valid())
	var rampart := BattleMoves._rampart(walled)
	var wall: Array[Combatant] = rampart.call()
	assert_eq(wall[0].max_hp, CoralCitadelRampart.combatant_of(walled.player.buildings).max_hp)
	var with_wall: float = rate.call(walled, rampart)
	var without: float = rate.call(bare, Callable())
	assert_true(with_wall >= without)


func test_a_base_holds_without_what_leaves_it_only_if_the_rest_beats_every_threat() -> void:
	var turn := _turn({HARPOONIST: 300})
	assert_true(BattleMoves.holds_without(turn, {HARPOONIST: 290}, _planner), "no threat")
	turn.player.raid_state.announce(_wave(3), 14)
	assert_true(BattleMoves.holds_without(turn, {HARPOONIST: 100}, _planner))
	assert_false(BattleMoves.holds_without(turn, {HARPOONIST: 300}, _planner))
	turn.player.raid_state.clear_incoming()
	turn.player.raid_state.attacks.append(AnnouncedAttack.new("rival", {HARPOONIST: 120}, 12, 1))
	assert_false(BattleMoves.holds_without(turn, {HARPOONIST: 250}, _planner))
	assert_true(BattleMoves.holds_without(turn, {}, _planner))


## `_underRaid` of hunt_under_raid_test.dart without the raid: a weak lair
## in sight of the base.
func _hunt(harpoonists: int, lair_size := 2) -> Dictionary:
	var game := GameFactory.new_single_player("Nemo", 3)
	game.turn = 20
	var player := game.human_player()
	var map := game.levels[1]
	var at: GridPosition = null
	for p: GridPosition in player.revealed_cells_on_level(1):
		if map.cell_at(p.x, p.y).content == CellContentType.Value.EMPTY:
			at = p
			break
	map.set_cell(at.x, at.y, map.cell_at(at.x, at.y).copy_with({
		"content": CellContentType.Value.MONSTER_LAIR, "lair": _wave(lair_size),
	}))
	player.units_on_level(1)[HARPOONIST].count = harpoonists
	player.units_on_level(1)[UnitType.Value.ABYSS_ADMIRAL].count = 1
	return {"game": game, "at": at}


func test_the_lairs_a_share_of_the_home_army_beats_are_cleared() -> void:
	var w := _hunt(200)
	var game: Game = w["game"]
	var at: GridPosition = w["at"]
	BattleMoves.hunt_lairs(ScriptSamples.turn(game), _planner)
	assert_true(game.levels[1].cell_at(at.x, at.y).is_collected())
	assert_eq(game.human_player().units_on_level(1)[UnitType.Value.ABYSS_ADMIRAL].count, 1)


func test_a_lair_too_strong_or_an_army_of_admirals_alone_clears_nothing() -> void:
	for w: Dictionary in [_hunt(1, 30), _hunt(0)]:
		var game: Game = w["game"]
		var at: GridPosition = w["at"]
		BattleMoves.hunt_lairs(ScriptSamples.turn(game), _planner)
		assert_false(game.levels[1].cell_at(at.x, at.y).is_collected())

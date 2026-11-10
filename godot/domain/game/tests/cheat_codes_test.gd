extends TestCase
## test/domain/game/cheat_codes_test.dart: the name that fills a base.

const Type := BuildingType.Value

var _player: Player


func before_each() -> void:
	_player = Player.new("qnope")
	CheatCodes.apply(_player)


func test_cheat_codes_apply_with_the_cheat_name_fills_every_resource_to_5000() -> void:
	for resource: GameResource in _player.resources.values():
		assert_eq(resource.amount, 5000, DartEnum.name_of(ResourceType.Value, resource.type))


func test_cheat_codes_apply_with_the_cheat_name_raises_the_headquarters_to_7_and_core_buildings_to_3() -> void:
	assert_eq(_player.buildings[Type.HEADQUARTERS].level, 7)
	for type: Type in [
		Type.ALGAE_FARM, Type.CORAL_MINE, Type.ORE_EXTRACTOR, Type.SOLAR_PANEL, Type.LABORATORY,
		Type.BARRACKS,
	]:
		assert_eq(_player.buildings[type].level, 3, DartEnum.name_of(Type, type))


func test_cheat_codes_apply_with_the_cheat_name_unlocks_every_tech_branch_at_research_level_3() -> void:
	for branch: TechBranch.Value in TechBranch.Value.values():
		var state := _player.tech_branches[branch]
		assert_true(state.unlocked, DartEnum.name_of(TechBranch.Value, branch))
		assert_eq(state.research_level, 3, DartEnum.name_of(TechBranch.Value, branch))


func test_cheat_codes_apply_with_the_cheat_name_stocks_the_base_with_scouts_harpoonists_and_admirals() -> void:
	var units := _player.units_on_level(1)
	assert_eq(units[UnitType.Value.SCOUT].count, 200)
	assert_eq(units[UnitType.Value.HARPOONIST].count, 200)
	assert_eq(units[UnitType.Value.ABYSS_ADMIRAL].count, 10)


func test_skips_branches_the_player_does_not_track() -> void:
	var none: Dictionary[TechBranch.Value, TechBranchState] = {}
	var player := Player.new("qnope", null, 0, 0, null, null, none)
	CheatCodes.apply(player)
	assert_eq(player.tech_branches.size(), 0)


## Not in the Dart file: a base without the buildings or the units the
## cheat raises keeps what it has.
func test_skips_the_buildings_and_units_the_player_does_not_have() -> void:
	var units: Dictionary[int, Dictionary] = {}
	var player := Player.new("qnope", null, 0, 0, null, DomainSamples.buildings({}), null, units)
	CheatCodes.apply(player)
	assert_eq(player.buildings.size(), 0)
	assert_eq(player.units_per_level.size(), 0)


func test_any_other_name_leaves_the_player_untouched() -> void:
	var player := Player.new("Nemo")
	var before := Player.new("Nemo")
	CheatCodes.apply(player)
	for type: ResourceType.Value in player.resources:
		assert_eq(player.resources[type].amount, before.resources[type].amount)
	for type: Type in player.buildings:
		assert_eq(player.buildings[type].level, before.buildings[type].level)
	for state: TechBranchState in player.tech_branches.values():
		assert_false(state.unlocked)
		assert_eq(state.research_level, 0)
	assert_eq(
		player.units_on_level(1)[UnitType.Value.SCOUT].count,
		before.units_on_level(1)[UnitType.Value.SCOUT].count,
	)


func test_the_cheat_name_is_case_sensitive() -> void:
	var player := Player.new("QNOPE")
	CheatCodes.apply(player)
	for resource: GameResource in player.resources.values():
		assert_ne(resource.amount, 5000)

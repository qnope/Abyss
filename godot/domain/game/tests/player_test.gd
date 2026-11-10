extends TestCase
## test/domain/game/player_test.dart, its groups 'Player construction and
## ids' and 'Player defaults'; the others are in player_base_test.gd.

const Branch := TechBranch.Value
const ResType := ResourceType.Value


func test_player_construction_and_ids_assigns_a_unique_uuid_when_id_is_omitted() -> void:
	var a := Player.new("A")
	var b := Player.new("B")
	assert_false(a.id.is_empty())
	assert_false(b.id.is_empty())
	assert_ne(a.id, b.id)


func test_player_construction_and_ids_preserves_an_explicit_id() -> void:
	assert_eq(Player.new("A", "fixed-id").id, "fixed-id")


func test_player_construction_and_ids_default_base_x_base_y_are_zero() -> void:
	var p := Player.new("A")
	assert_eq(p.base_x, 0)
	assert_eq(p.base_y, 0)


func test_player_defaults_default_resources_contain_all_5_types_with_correct_max_storage() -> void:
	var p := Player.new("A")
	assert_eq(p.resources.size(), 5)
	assert_eq(p.resources[ResType.ALGAE].max_storage, 5000)
	assert_eq(p.resources[ResType.CORAL].max_storage, 5000)
	assert_eq(p.resources[ResType.ORE].max_storage, 5000)
	assert_eq(p.resources[ResType.ENERGY].max_storage, 2000)
	assert_eq(p.resources[ResType.PEARL].max_storage, 100)


func test_player_defaults_default_buildings_contain_11_buildings_at_level_0() -> void:
	var p := Player.new("A")
	assert_eq(p.buildings.size(), 11)
	for type: BuildingType.Value in BuildingType.Value.values():
		assert_eq(p.buildings[type].level, 0)


func test_player_defaults_default_tech_branches_are_locked_at_level_0() -> void:
	var p := Player.new("A")
	assert_eq(p.tech_branches.size(), 3)
	for branch: Branch in Branch.values():
		assert_false(p.tech_branches[branch].unlocked)
		assert_eq(p.tech_branches[branch].research_level, 0)


func test_player_defaults_default_units_contain_all_6_unit_types_at_count_0() -> void:
	var units := Player.new("A").units_on_level(1)
	assert_eq(units.size(), UnitType.Value.size())
	for unit: Unit in units.values():
		assert_eq(unit.count, 0)


func test_player_defaults_units_on_level_returns_empty_map_for_absent_level() -> void:
	assert_eq(Player.new("A").units_on_level(2), {} as Dictionary[UnitType.Value, Unit])


func test_player_defaults_unit_count_on_level_counts_the_units_by_type_empty_ones_left_out() -> void:
	var p := Player.new("A")
	p.units_on_level(1)[UnitType.Value.GUARDIAN].count = 4
	assert_eq(p.unit_counts_on_level(1), {UnitType.Value.GUARDIAN: 4} as Dictionary[UnitType.Value, int])
	assert_eq(p.unit_counts_on_level(2), {} as Dictionary[UnitType.Value, int])


func test_player_defaults_default_recruited_unit_types_and_pending_explorations_are_empty() -> void:
	var p := Player.new("A")
	assert_eq(p.recruited_unit_types.size(), 0)
	assert_eq(p.pending_explorations.size(), 0)
	assert_eq(p.revealed_cells_per_level.size(), 0)

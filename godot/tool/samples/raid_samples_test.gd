extends TestCase
## The bases and kernels the tests of the raids and of the volcano share.

const HARPOONIST := UnitType.Value.HARPOONIST
const SCOUT := UnitType.Value.SCOUT


func test_a_raid_player_holds_1000_of_everything_and_the_units_given() -> void:
	var player := RaidSamples.raid_player({HARPOONIST: 4, SCOUT: 2}, 3, 2)
	assert_eq([player.id, player.name], ["p1", "Test"])
	for stock: GameResource in player.resources.values():
		assert_eq([stock.amount, stock.max_storage], [1000, 100000])
	assert_eq(player.resources.keys(), ResourceType.Value.values())
	assert_eq(Building.level_in(player.buildings, BuildingType.Value.CORAL_CITADEL), 3)
	assert_eq(Building.level_in(player.buildings, BuildingType.Value.HEADQUARTERS), 2)
	assert_eq(player.buildings.size(), 11)
	assert_eq(player.unit_counts_on_level(1), {SCOUT: 2, HARPOONIST: 4})
	assert_eq(RaidSamples.units_on_base(player), 6)


func test_a_bare_raid_player_has_no_unit_and_buildings_at_level_0() -> void:
	var player := RaidSamples.raid_player()
	assert_eq(RaidSamples.units_on_base(player), 0)
	assert_eq(Building.level_in(player.buildings, BuildingType.Value.CORAL_CITADEL), 0)


func test_a_wave_reads_as_its_five_fields() -> void:
	var wave := MonsterLair.new(
		MonsterDifficulty.Value.HARD, 4, MonsterFamily.Value.COLOSSUS, MonsterFamily.Value.SWARM, 30
	)
	assert_eq(
		RaidSamples.wave_fields(wave),
		[MonsterDifficulty.Value.HARD, MonsterFamily.Value.COLOSSUS, 4, MonsterFamily.Value.SWARM, 30],
	)


func test_a_wave_shares_its_generic_monsters_the_first_family_taking_more() -> void:
	var wave := MonsterLair.new(
		MonsterDifficulty.Value.HARD, 0, MonsterFamily.Value.COLOSSUS, MonsterFamily.Value.SWARM, 0
	)
	# 7 generic: 4 for the colossi (one for six, at least one), 3 for the
	# swarm (three for one).
	assert_eq(RaidSamples.shared_counts(wave, 7), [1, 9])


func test_a_volcano_player_holds_its_kernel_its_garrison_and_its_volcano_units() -> void:
	var player := RaidSamples.volcano_player(4, {UnitType.Value.GUARDIAN: 5}, {HARPOONIST: 3})
	assert_eq([player.id, player.name], ["p1", "Test"])
	assert_eq(KernelGarrison.kernel_level_of(player), 4)
	assert_eq(KernelGarrison.of(player), {UnitType.Value.GUARDIAN: 5})
	assert_eq(player.unit_counts_on_level(KernelGarrison.VOLCANO_LEVEL), {HARPOONIST: 3})
	assert_eq(RaidSamples.volcano_player().unit_counts_on_level(KernelGarrison.VOLCANO_LEVEL), {})


func test_a_kernel_garrison_game_holds_the_kernel_on_the_volcano_level() -> void:
	var game := RaidSamples.kernel_garrison_game(true, 2, 1)
	var human := game.human_player()
	assert_eq(human.name, "Nemo")
	assert_eq(KernelGarrison.kernel_level_of(human), 1)
	assert_eq(human.unit_counts_on_level(KernelGarrison.VOLCANO_LEVEL), {SCOUT: 2})
	assert_eq(KernelGarrison.of(human), {SCOUT: 1})
	var cell := game.levels[KernelGarrison.VOLCANO_LEVEL].cell_at(0, 0)
	assert_eq([cell.content, cell.collected_by], [CellContentType.Value.VOLCANIC_KERNEL, human.id])
	var free := RaidSamples.kernel_garrison_game(false)
	assert_null(free.levels[KernelGarrison.VOLCANO_LEVEL].cell_at(0, 0).collected_by)


func test_set_units_puts_a_new_stock_on_a_level() -> void:
	var player := GameSamples.player("p")
	RaidSamples.set_units(player, HARPOONIST, 40, 4)
	RaidSamples.set_units(player, SCOUT, 2)
	assert_eq(player.unit_counts_on_level(4), {HARPOONIST: 40})
	assert_eq(player.unit_counts_on_level(1), {SCOUT: 2})

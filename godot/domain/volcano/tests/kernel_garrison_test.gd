extends TestCase
## Not in the Dart files: lib/domain/volcano/kernel_garrison.dart has no test
## of its own, the Dart tests read it through the garrison action (the
## action module) and the helpers of the volcano tests. What it answers, as
## its Dart code says.

const SCOUT := UnitType.Value.SCOUT
const GUARDIAN := UnitType.Value.GUARDIAN
const KEY := KernelGarrison.STOCK_KEY


func test_the_garrison_lives_one_step_below_the_volcano() -> void:
	assert_eq([KernelGarrison.VOLCANO_LEVEL, KernelGarrison.STOCK_KEY], [3, 4])


func test_a_player_without_a_garrison_has_none_and_keeps_none() -> void:
	var player := GameSamples.player("p")
	assert_eq(KernelGarrison.of(player), {})
	assert_eq(KernelGarrison.size_of(player), 0)
	assert_false(player.units_per_level.has(KEY))


func test_the_stock_is_created_with_every_unit_type_in_their_order() -> void:
	var player := GameSamples.player("p")
	var stock := KernelGarrison.stock_of(player)
	assert_eq(stock.keys(), UnitType.Value.values())
	assert_true(player.units_per_level[KEY] == stock)
	assert_true(KernelGarrison.stock_of(player) == stock)


func test_a_stock_keeps_its_units_and_gets_the_missing_types_after_them() -> void:
	var player := GameSamples.player("p")
	var held: Dictionary[UnitType.Value, Unit] = {GUARDIAN: Unit.new(GUARDIAN, 5)}
	player.units_per_level[KEY] = held
	var stock := KernelGarrison.stock_at(player, KEY)
	assert_eq(stock.keys()[0], GUARDIAN)
	assert_eq(stock.size(), UnitType.Value.size())
	assert_eq(stock[GUARDIAN].count, 5)


func test_counts_the_garrison_empty_types_left_out() -> void:
	var player := GameSamples.player("p")
	var stock := KernelGarrison.stock_of(player)
	stock[GUARDIAN].count = 5
	stock[SCOUT].count = 2
	assert_eq(KernelGarrison.of(player), {SCOUT: 2, GUARDIAN: 5})
	assert_eq(KernelGarrison.size_of(player), 7)


func test_reads_the_level_of_the_kernel() -> void:
	var player := GameSamples.player("p")
	assert_eq(KernelGarrison.kernel_level_of(player), 0)
	player.buildings[BuildingType.Value.VOLCANIC_KERNEL].level = 6
	assert_eq(KernelGarrison.kernel_level_of(player), 6)
	assert_eq(KernelGarrison.kernel_level_of(GameSamples.player_with("q", {})), 0)


## Not in the Dart file either: the tuning of the rampart and the waves.
func test_the_rampart_and_the_waves_are_tuned_as_in_dart() -> void:
	assert_eq(
		[MagmaRampart.TYPE_KEY, MagmaRampart.HP_PER_LEVEL, MagmaRampart.BASE_ATK, MagmaRampart.BASE_DEF],
		["magmaRampart", 40, 4, 3],
	)
	assert_eq([VolcanoWaveFactory.BASE_KRAKENS, VolcanoWaveFactory.KRAKENS_PER_THREE_LEVELS], [2, 4])

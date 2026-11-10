class_name RaidSamples
extends RefCounted
## The bases and kernels the tests of the raids and of the volcano strike:
## the twins of test/domain/raid/raid_test_helper.dart, test/domain/volcano/
## volcano_test_helper.dart and test/helpers/kernel_garrison_helpers.dart.


## `raidPlayer`: player "p1" named "Test" with 1000 of every resource (under
## a storage of 100000), `units` on the base level, a Coral Citadel at
## `citadel_level` and a headquarters at `headquarters_level`, whose income
## caps the loot of a raid.
static func raid_player(
	units: Dictionary[UnitType.Value, int] = {}, citadel_level := 0, headquarters_level := 0
) -> Player:
	var resources: Dictionary[ResourceType.Value, GameResource] = {}
	for type: ResourceType.Value in ResourceType.Value.values():
		resources[type] = GameResource.new(type, 1000, 100000)
	var player := Player.new("Test", "p1", 0, 0, resources)
	var citadel := BuildingType.Value.CORAL_CITADEL
	var headquarters := BuildingType.Value.HEADQUARTERS
	player.buildings[citadel] = Building.new(citadel, citadel_level)
	player.buildings[headquarters] = Building.new(headquarters, headquarters_level)
	for type: UnitType.Value in units:
		player.units_on_level(1)[type].count = units[type]
	return player


## `unitsOnBase`: every unit on the base level.
static func units_on_base(player: Player) -> int:
	var total := 0
	for unit: Unit in player.units_on_level(1).values():
		total += unit.count
	return total


## The five fields of `wave`, as `expectSameWave` of
## raid_wave_factory_test.dart compares them.
static func wave_fields(wave: MonsterLair) -> Array:
	return [wave.difficulty, wave.family, wave.unit_count, wave.second_family, wave.second_count]


## The two counts `expectShared` expects of `wave` holding `generic` generic
## monsters, the first family taking the larger half.
static func shared_counts(wave: MonsterLair, generic: int) -> Array[int]:
	var first := DartMath.trunc_div(generic + 1, 2)
	return [
		MonsterUnitStats.count_for(wave.family, first),
		MonsterUnitStats.count_for(wave.second_family, generic - first),
	]


## `volcanoPlayer`: player "p1" named "Test" whose kernel stands at
## `kernel_level`, with `garrison` in it and `on_volcano` on the volcano
## level.
static func volcano_player(
	kernel_level := 1,
	garrison: Dictionary[UnitType.Value, int] = {},
	on_volcano: Dictionary[UnitType.Value, int] = {},
) -> Player:
	var player := Player.new("Test", "p1")
	player.buildings[BuildingType.Value.VOLCANIC_KERNEL].level = kernel_level
	var stock := KernelGarrison.stock_of(player)
	for type: UnitType.Value in garrison:
		stock[type].count = garrison[type]
	var volcano := KernelGarrison.stock_at(player, KernelGarrison.VOLCANO_LEVEL)
	for type: UnitType.Value in on_volcano:
		volcano[type].count = on_volcano[type]
	return player


## `kernelGarrisonGame`: a single-player game of "Nemo", its kernel at level
## 1, whose volcano level holds the kernel (captured by the human when
## `captured`), with `on_volcano` scouts on the volcano level and
## `garrisoned` scouts in the kernel.
static func kernel_garrison_game(captured := true, on_volcano := 3, garrisoned := 0) -> Game:
	var volcano: Dictionary[UnitType.Value, Unit] = {UnitType.Value.SCOUT: Unit.new(UnitType.Value.SCOUT, on_volcano)}
	var kernel: Dictionary[UnitType.Value, Unit] = {UnitType.Value.SCOUT: Unit.new(UnitType.Value.SCOUT, garrisoned)}
	var per_level: Dictionary[int, Dictionary] = {
		KernelGarrison.VOLCANO_LEVEL: volcano, KernelGarrison.STOCK_KEY: kernel
	}
	var player := Player.new("Nemo", null, 0, 0, null, null, null, per_level)
	player.buildings[BuildingType.Value.VOLCANIC_KERNEL].level = 1
	var game := Game.single_player(player)
	var cell := MapCell.new(
		TerrainType.Value.PLAIN, CellContentType.Value.VOLCANIC_KERNEL, null, player.id if captured else null
	)
	game.levels = {KernelGarrison.VOLCANO_LEVEL: GameMap.new(1, 1, [cell], 0)}
	return game


## `setUnits` of test/helpers/objective_helpers.dart: a new stock of `count`
## units of `type` on `level`, the level created when missing.
static func set_units(player: Player, type: UnitType.Value, count: int, level := 1) -> void:
	if not player.units_per_level.has(level):
		var created: Dictionary[UnitType.Value, Unit] = {}
		player.units_per_level[level] = created
	var units: Dictionary[UnitType.Value, Unit] = player.units_per_level[level]
	units[type] = Unit.new(type, count)

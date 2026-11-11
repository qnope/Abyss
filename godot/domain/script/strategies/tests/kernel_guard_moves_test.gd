extends TestCase
## Not in the Dart files (the kernel guard plays in whole games): a faction
## shuts its fighters in the kernel it holds and brings down what the next
## wave asks for.

const HARPOONIST := UnitType.Value.HARPOONIST
const BREAKER := UnitType.Value.DOME_BREAKER

var _planner := ArmyPlanner.new()


## The first faction of DeepScouts holding both posts and the kernel at
## `level`, rich, its barracks at 5.
func _guard(level := 1) -> DeepScouts:
	var deep := DeepScouts.new()
	deep.hold(TransitionBaseType.Value.FAILLE)
	deep.hold(TransitionBaseType.Value.CHEMINEE)
	var faction := deep.faction()
	faction.buildings[BuildingType.Value.HEADQUARTERS].level = 10
	faction.buildings[BuildingType.Value.BARRACKS].level = 5
	faction.buildings[BuildingType.Value.VOLCANIC_KERNEL].level = level
	for r: GameResource in faction.resources.values():
		r.amount = 100000
	var map := deep.game.levels[3]
	for at: GridPosition in deep.kernel():
		map.set_cell(at.x, at.y, map.cell_at(at.x, at.y).copy_with({"collected_by": faction.id}))
	return deep


func test_a_kernel_not_held_or_at_level_0_is_left_alone() -> void:
	var free := DeepScouts.new()
	KernelGarrison.stock_at(free.faction(), 3)[HARPOONIST].count = 5
	KernelGuardMoves.guard_kernel(free.turn(), _planner)
	assert_eq(KernelGarrison.size_of(free.faction()), 0)
	var cold := _guard(0)
	KernelGarrison.stock_at(cold.faction(), 3)[HARPOONIST].count = 5
	KernelGuardMoves.guard_kernel(cold.turn(), _planner)
	assert_eq(KernelGarrison.size_of(cold.faction()), 0)


func test_the_fighters_of_the_volcano_and_the_recruits_go_in_the_garrison() -> void:
	var deep := _guard()
	var volcano := KernelGarrison.stock_at(deep.faction(), 3)
	volcano[HARPOONIST].count = 5
	volcano[UnitType.Value.ABYSS_ADMIRAL].count = 1
	KernelGuardMoves.guard_kernel(deep.turn(), _planner)
	var garrison := KernelGarrison.of(deep.faction())
	var harpoonists: int = garrison.get(HARPOONIST, 0)
	var breakers: int = garrison.get(BREAKER, 0)
	assert_true(harpoonists >= 5)
	assert_true(breakers > 0, "recruited at home, brought down")
	assert_eq(volcano[UnitType.Value.ABYSS_ADMIRAL].count, 1)
	assert_eq(deep.faction().units_on_level(1)[BREAKER].count, 0)


func test_a_garrison_strong_enough_recruits_nobody() -> void:
	var deep := _guard()
	KernelGarrison.stock_of(deep.faction())[BREAKER].count = 500
	KernelGuardMoves.guard_kernel(deep.turn(), _planner)
	assert_eq(deep.faction().units_on_level(1)[BREAKER].count, 0)
	assert_eq(KernelGarrison.of(deep.faction()), {BREAKER: 500} as Dictionary[UnitType.Value, int])

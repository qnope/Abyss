extends TestCase
## test/domain/objective/building_objectives_test.dart: the objectives that
## ask a building at a level, past the tutorial.

const Id := ObjectiveId.Value
const Type := BuildingType.Value


func test_building_objectives_hq_level_5_qg_au_niveau_5() -> void:
	_expect_building_goal(Id.HQ_LEVEL_5, Type.HEADQUARTERS, 5)


func test_building_objectives_coral_citadel_citadelle_construite() -> void:
	_expect_building_goal(Id.CORAL_CITADEL, Type.CORAL_CITADEL, 1)


func test_building_objectives_descent_module_module_de_descente_construit() -> void:
	_expect_building_goal(Id.DESCENT_MODULE, Type.DESCENT_MODULE, 1)


func test_building_objectives_hq_level_8_qg_au_niveau_8() -> void:
	_expect_building_goal(Id.HQ_LEVEL_8, Type.HEADQUARTERS, 8)


func test_building_objectives_pressure_capsule_capsule_construite() -> void:
	_expect_building_goal(Id.PRESSURE_CAPSULE, Type.PRESSURE_CAPSULE, 1)


func test_building_objectives_hq_level_10_qg_au_niveau_10() -> void:
	_expect_building_goal(Id.HQ_LEVEL_10, Type.HEADQUARTERS, 10)


func test_building_objectives_kernel_level_1_noyau_au_niveau_1() -> void:
	_expect_building_goal(Id.KERNEL_LEVEL_1, Type.VOLCANIC_KERNEL, 1)


func test_building_objectives_kernel_level_5_noyau_au_niveau_5() -> void:
	_expect_building_goal(Id.KERNEL_LEVEL_5, Type.VOLCANIC_KERNEL, 5)


func test_building_objectives_kernel_level_10_noyau_au_niveau_10() -> void:
	_expect_building_goal(Id.KERNEL_LEVEL_10, Type.VOLCANIC_KERNEL, 10)


func test_building_objectives_a_higher_level_stays_capped_at_the_target() -> void:
	var game := ObjectiveSamples.objective_game()
	ObjectiveSamples.set_building(game.human_player(), Type.HEADQUARTERS, 9)
	assert_eq(ObjectiveSamples.progress(game, Id.HQ_LEVEL_5), ObjectiveSamples.expected(5, 5))


## `expectBuildingGoal`: `id` asks `type` at `level`; one level short counts
## `level - 1`, `level` completes it.
func _expect_building_goal(id: Id, type: Type, level: int) -> void:
	var game := ObjectiveSamples.objective_game()
	var name := DartEnum.name_of(Id, id)
	assert_eq(ObjectiveSamples.progress(game, id), ObjectiveSamples.expected(0, level), name)
	ObjectiveSamples.set_building(game.human_player(), type, level - 1)
	assert_eq(ObjectiveSamples.progress(game, id), ObjectiveSamples.expected(level - 1, level), name)
	ObjectiveSamples.set_building(game.human_player(), type, level)
	assert_eq(ObjectiveSamples.progress(game, id), ObjectiveSamples.expected(level, level), name)

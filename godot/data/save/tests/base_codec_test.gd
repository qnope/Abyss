extends CodecTestCase
## BaseCodec: what a base holds, written and read back.


func test_a_resource_keeps_its_amount_and_storage() -> void:
	assert_round_trip(BaseSnapshots.resource(), BaseCodec.resource, BaseCodec.read_resource,
		GameResource.new(ResourceType.Value.PEARL, 42, 100))
	var text := JSON.stringify(BaseCodec.resource(GameResource.new(ResourceType.Value.ALGAE, 7, 5000)), "", false)
	assert_eq(text, "{\"type\":\"algae\",\"amount\":7,\"maxStorage\":5000}")


## Through the constructor, as Dart's adapter: a small energy storage is
## lifted.
func test_a_small_energy_storage_is_lifted_as_dart_reads_it() -> void:
	var r := SaveReader.new()
	var read := BaseCodec.read_resource(r, {"type": "energy", "amount": 1.0, "maxStorage": 1.0})
	assert_eq(read.max_storage, GameResource.MIN_ENERGY_STORAGE)


func test_a_building_a_branch_and_units_keep_their_levels() -> void:
	assert_round_trip(BaseSnapshots.building(), BaseCodec.building, BaseCodec.read_building,
		Building.new(BuildingType.Value.ALGAE_FARM, 3))
	var choices: Array[int] = [1, 0, 1]
	assert_round_trip(BaseSnapshots.tech_branch(), BaseCodec.tech_branch, BaseCodec.read_tech_branch,
		TechBranchState.new(TechBranch.Value.RESOURCES, true, 3, choices))
	assert_round_trip(BaseSnapshots.unit(), BaseCodec.unit, BaseCodec.read_unit, Unit.new(UnitType.Value.SCOUT, 9))


func test_the_work_started_and_the_objectives() -> void:
	assert_round_trip(BaseSnapshots.worksite(), BaseCodec.worksite, BaseCodec.read_worksite, Worksite.new(1, 2))
	var completed: Array[ObjectiveId.Value] = [ObjectiveId.Value.MINES, ObjectiveId.Value.HQ_LEVEL_1]
	var tips: Array[TipId.Value] = [TipId.Value.WORKSITES]
	assert_round_trip(PlayerSnapshots.objectives(), BaseCodec.objectives, BaseCodec.read_objectives,
		ObjectiveState.new(completed, true, true, tips))
	assert_round_trip(PlayerSnapshots.objectives(), BaseCodec.objectives, BaseCodec.read_objectives,
		ObjectiveState.new())


func test_a_field_of_the_wrong_type_is_a_problem() -> void:
	assert_eq(problem_of(BaseCodec.read_unit, "{\"type\":\"scout\",\"count\":\"9\"}"), "count is not a whole number")
	assert_eq(problem_of(BaseCodec.read_building, "[]"), "Building is not an object")
	assert_eq(problem_of(BaseCodec.read_tech_branch, "{\"branch\":\"x\"}"),
		"branch: \"x\" is no %s" % "|".join(DartEnum.names(TechBranch.Value)))

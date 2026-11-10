extends TestCase
## test/domain/resource/resource_test.dart: a stock of one resource.

const ALGAE := ResourceType.Value.ALGAE


func test_resource_creates_with_required_fields() -> void:
	var r := GameResource.new(ALGAE, 100)
	assert_eq(r.type, ALGAE)
	assert_eq(r.amount, 100)


func test_resource_defaults_max_storage_500() -> void:
	var r := GameResource.new(ALGAE, 50)
	assert_eq(r.max_storage, 500)


func test_resource_accepts_custom_max_storage() -> void:
	var r := GameResource.new(ResourceType.Value.CORAL, 200, 1000)
	assert_eq(r.max_storage, 1000)


func test_resource_energy_storage_never_drops_below_the_research_cost_ceiling() -> void:
	# A save made when the cap was 1000 must still pay 1048 energy.
	var r := GameResource.new(ResourceType.Value.ENERGY, 0, 1000)
	assert_eq(r.max_storage, GameResource.MIN_ENERGY_STORAGE)
	assert_eq(GameResource.MIN_ENERGY_STORAGE, 2000)


func test_resource_amount_is_mutable() -> void:
	var r := GameResource.new(ResourceType.Value.ORE, 10)
	r.amount = 20
	assert_eq(r.amount, 20)


## Not in the Dart file: `resources[type]?.amount ?? 0`.
func test_reads_the_amount_of_a_resource_in_a_map_0_when_it_is_missing() -> void:
	var resources := DomainSamples.resources({ALGAE: 7})
	assert_eq(GameResource.amount_in(resources, ALGAE), 7)
	assert_eq(GameResource.amount_in(resources, ResourceType.Value.ORE), 0)
	assert_eq(GameResource.amount_in({}, ALGAE), 0)

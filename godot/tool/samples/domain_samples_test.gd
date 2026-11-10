extends TestCase
## The sample states the tests of the domain share.

const HQ := BuildingType.Value.HEADQUARTERS
const FARM := BuildingType.Value.ALGAE_FARM
const SCOUT := UnitType.Value.SCOUT
const ORE := ResourceType.Value.ORE


func test_builds_the_buildings_given_in_their_order() -> void:
	var built := DomainSamples.buildings({FARM: 3, HQ: 2})
	assert_eq(built.keys(), [FARM, HQ])
	assert_eq(built[FARM].type, FARM)
	assert_eq(built[FARM].level, 3)
	assert_eq(DomainSamples.buildings({}), {})


func test_builds_a_base_around_its_headquarters() -> void:
	var built := DomainSamples.base(4, {FARM: 3})
	assert_eq(built.keys(), [HQ, FARM])
	assert_eq(built[HQ].level, 4)
	assert_eq(DomainSamples.base(1).keys(), [HQ])


func test_builds_an_army() -> void:
	var army := DomainSamples.units({SCOUT: 10})
	assert_eq(army[SCOUT].type, SCOUT)
	assert_eq(army[SCOUT].count, 10)


func test_builds_stocks_under_a_storage() -> void:
	assert_eq(DomainSamples.resources({ORE: 10})[ORE].max_storage, 500)
	var stocks := DomainSamples.resources({ORE: 10}, 5000)
	assert_eq(stocks[ORE].amount, 10)
	assert_eq(stocks[ORE].max_storage, 5000)

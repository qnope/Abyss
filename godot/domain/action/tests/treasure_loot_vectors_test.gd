extends VectorTestCase
## reference/vectors/fight_aftermath.json, treasureLoot: what a treasure,
## ruins or a wreck hold, as TreasureLoot.of answers it. Not in the Dart
## files: lib/domain/action/treasure_loot.dart has no test of its own.

const ALGAE := ResourceType.Value.ALGAE
const CORAL := ResourceType.Value.CORAL
const ORE := ResourceType.Value.ORE
const PEARL := ResourceType.Value.PEARL


func test_treasure_loot() -> void:
	var cases := VectorFile.new("fight_aftermath").cases("treasureLoot")
	assert_eq(cases.size(), 90)
	for case: Dictionary in cases:
		var seed_: int = case["seed"]
		var level: int = case["level"]
		var content := VectorInputs.value(CellContentType.Value, case["content"]) as CellContentType.Value
		var loot := TreasureLoot.of(content, DartRandom.new(seed_), level)
		assert_same(VectorInputs.named(ResourceType.Value, loot), case["out"], str(case))


## The vectors write a map with sorted keys: the order of the entries, which
## is the order of the deltas of a search, is held here.
func test_the_loot_keeps_the_order_of_dart() -> void:
	var bonus := TreasureLoot.of(CellContentType.Value.RESOURCE_BONUS, DartRandom.new(1), 1)
	var ruins := TreasureLoot.of(CellContentType.Value.RUINS, DartRandom.new(1), 2)
	var wreck := TreasureLoot.of(CellContentType.Value.WRECK, DartRandom.new(1), 1)
	assert_eq([bonus.keys(), ruins.keys(), wreck.keys()], [[ALGAE, CORAL, ORE], [ALGAE, CORAL, ORE, PEARL], [CORAL, ORE, PEARL]])
	assert_eq(wreck, {CORAL: EventRules.WRECK_CORAL, ORE: EventRules.WRECK_ORE, PEARL: EventRules.WRECK_PEARLS})
	assert_eq(TreasureLoot.of(CellContentType.Value.EMPTY, DartRandom.new(1), 1), {})

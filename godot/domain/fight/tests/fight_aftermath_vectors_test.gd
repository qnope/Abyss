extends VectorTestCase
## reference/vectors/fight_aftermath.json: the wounded, the dead and the loot
## a fight leaves, as the Dart rules answer. pctLost and treasureLoot wait
## for the action module (FightMonsterHelpers, TreasureLoot).

var _vectors := VectorFile.new("fight_aftermath")


func test_wounded_probability() -> void:
	var cases := _vectors.cases("woundedProbability")
	assert_eq(cases.size(), 28)
	for case: Dictionary in cases:
		var lost: float = case["pctLost"]
		assert_same(CasualtyCalculator.wounded_probability(lost), case["out"], str(case))


func test_casualties() -> void:
	var cases := _vectors.cases("casualties")
	assert_eq(cases.size(), 60)
	for case: Dictionary in cases:
		var seed_: int = case["seed"]
		var lost: float = case["pctLost"]
		var keys: Array = case["fallen"]
		var fallen: Array[Combatant] = []
		for key: String in keys:
			fallen.append(Combatant.new(CombatSide.Value.PLAYER, key, 10, 1, 1, 0))
		var split := CasualtyCalculator.new(DartRandom.new(seed_)).partition(fallen, lost)
		var out := {"wounded": _keys(split.wounded), "dead": _keys(split.dead)}
		assert_same(out, case["out"], str(case))


func test_lair_loot() -> void:
	var cases := _vectors.cases("lairLoot")
	assert_eq(cases.size(), 18)
	for case: Dictionary in cases:
		var seed_: int = case["seed"]
		var difficulty := (
			VectorInputs.value(MonsterDifficulty.Value, case["difficulty"])
			as MonsterDifficulty.Value
		)
		var loot := LootCalculator.new(DartRandom.new(seed_)).compute(difficulty)
		assert_same(VectorInputs.named(ResourceType.Value, loot), case["out"], str(case))


func _keys(side: Array[Combatant]) -> Array:
	return side.map(func(c: Combatant) -> String: return c.type_key)

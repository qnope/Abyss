extends VectorTestCase
## test/domain/faction/faction_catalogue_test.dart: the ten personalities and
## the draw of the factions of a game. Then the draw section of
## factions.json.

const Personality := FactionPersonality.Value


func test_the_catalogue_holds_the_ten_personalities_each_with_a_name() -> void:
	assert_eq(Personality.size(), 10)
	var names: Dictionary[String, bool] = {}
	for personality: Personality in Personality.values():
		names[FactionPersonality.label(personality)] = true
	assert_eq(names.size(), 10)
	assert_has(names, "Les Pillards de l'Épave")
	assert_has(names, "Les Fidèles du Kraken")


func test_a_faction_takes_its_id_and_name_from_its_personality() -> void:
	var faction := Faction.new(Personality.SILENCE_MONKS)
	assert_eq(faction.id(), "faction-silenceMonks")
	assert_eq(faction.name(), "Les Moines du Silence")


func test_a_draw_has_no_duplicate_whatever_the_seed_and_the_count() -> void:
	for seed_: int in 40:
		for count: int in range(1, 11):
			var drawn := FactionCatalogue.draw(count, seed_)
			assert_eq(drawn.size(), count)
			var different: Dictionary[Personality, bool] = {}
			for personality: Personality in drawn:
				different[personality] = true
			assert_eq(different.size(), count)


func test_a_seed_always_draws_the_same_factions_in_the_same_order() -> void:
	assert_eq(FactionCatalogue.draw(5, 7), FactionCatalogue.draw(5, 7))


func test_other_seeds_draw_other_factions() -> void:
	var draws: Dictionary[String, bool] = {}
	for seed_: int in 20:
		draws[str(FactionCatalogue.draw(3, seed_))] = true
	assert_true(draws.size() > 5)


## Dart throws an ArgumentError: the port logs an error and draws nothing.
func test_a_draw_holds_1_to_10_factions() -> void:
	expect_error("FactionCatalogue.draw: the count 0 must be 1 to 10")
	assert_eq(FactionCatalogue.draw(0, 1), [] as Array[Personality])
	expect_error("FactionCatalogue.draw: the count 11 must be 1 to 10")
	assert_eq(FactionCatalogue.draw(11, 1), [] as Array[Personality])


func test_draws_the_factions_dart_draws() -> void:
	for case: Dictionary in VectorFile.new("factions").cases("draw"):
		var count: int = case["count"]
		var seed_: int = case["seed"]
		var drawn := FactionCatalogue.draw(count, seed_)
		assert_same(VectorInputs.names(Personality, drawn), case["out"], str(case))


## Not in the Dart file: the names the snapshots and the journals write.
func test_has_the_values_of_dart_in_its_order() -> void:
	assert_eq(
		DartEnum.names(Personality),
		PackedStringArray([
			"wreckPillagers", "pearlOrder", "anglerCult", "murenaHorde", "siphonophoreGuild",
			"silenceMonks", "currentNomads", "pyrosomeHive", "magmaSmiths", "krakenFaithful",
		]),
	)

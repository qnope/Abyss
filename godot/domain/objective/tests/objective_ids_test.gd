extends TestCase
## Not in the Dart tests: the objectives and the tip cards under the names
## and in the order Dart gives them (lib/domain/objective/objective_id.dart,
## tip/tip_id.dart), which the snapshots write. Dart tests both through
## their catalogues, which come with the objective module.


func test_the_objectives_have_the_values_of_dart_in_its_order() -> void:
	assert_eq(
		DartEnum.names(ObjectiveId.Value),
		PackedStringArray([
			"hqLevel1", "algaeFarm", "mines", "solarPanel", "hqLevel2", "barracksAndScouts",
			"explore", "solarPanelLevel2", "laboratoryAndResearch", "firstRaid", "takeLair",
			"hqLevel5", "coralCitadel", "takeFaille", "descentModule", "descendLevel2",
			"hqLevel8", "takeCheminee", "pressureCapsule", "descendLevel3", "hqLevel10",
			"takeKernel", "kernelLevel1", "kernelLevel5", "kernelLevel10",
		]),
	)


func test_the_tips_have_the_values_of_dart_in_its_order() -> void:
	assert_eq(
		DartEnum.names(TipId.Value),
		PackedStringArray([
			"noiseGauge", "worksites", "techChoice", "raidAnnounced", "raidReport",
			"lastChance", "lair", "monsterFamilies", "volcanoWave", "chestAndRuins",
			"transitionBase", "descent", "events", "warmCurrent", "wreck", "predators",
			"storm", "survivors", "caravan", "coldCurrent", "factionAttack", "admiral",
			"postDefence", "kernelGarrison", "postLost", "abyssListens", "rivalColonies",
			"ancients", "forgeTowers", "awakening",
		]),
	)

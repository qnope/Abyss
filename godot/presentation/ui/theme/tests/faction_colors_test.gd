extends TestCase
## The colour of each faction, on the map and in the ranking.


func test_gives_each_personality_its_constant() -> void:
	assert_eq(FactionColors.of(FactionPersonality.Value.WRECK_PILLAGERS), FactionColors.WRECK_PILLAGERS)
	assert_eq(FactionColors.of(FactionPersonality.Value.MAGMA_SMITHS), FactionColors.MAGMA_SMITHS)
	assert_eq(FactionColors.of(FactionPersonality.Value.KRAKEN_FAITHFUL), FactionColors.KRAKEN_FAITHFUL)


func test_no_two_factions_share_a_colour() -> void:
	var seen: Array[Color] = []
	for personality: FactionPersonality.Value in FactionPersonality.Value.values():
		assert_false(seen.has(FactionColors.of(personality)), str(personality))
		seen.append(FactionColors.of(personality))
	assert_eq(seen.size(), 10)

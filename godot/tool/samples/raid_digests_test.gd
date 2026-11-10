extends TestCase
## The texts of the digest tests of the raids and of the volcano.

const HARPOONIST := UnitType.Value.HARPOONIST


func test_arms_the_human_and_the_factions() -> void:
	var game := GameSamples.game([GameSamples.player("human"), GameSamples.player("f")])
	RaidDigests.arm_for_raids(game)
	var human := game.players["human"]
	assert_eq(human.unit_counts_on_level(1), {HARPOONIST: 15, UnitType.Value.GUARDIAN: 4})
	assert_eq(Building.level_in(human.buildings, BuildingType.Value.CORAL_CITADEL), 2)
	assert_eq(Building.level_in(human.buildings, BuildingType.Value.HEADQUARTERS), 3)
	assert_eq(game.players["f"].unit_counts_on_level(1), {HARPOONIST: 8})


func test_writes_a_wave_its_missing_families_as_null() -> void:
	var lair := MonsterLair.new(
		MonsterDifficulty.Value.MEDIUM, 5, MonsterFamily.Value.ARMOURED, MonsterFamily.Value.SWARM, 21
	)
	assert_eq(RaidDigests.wave(lair), "medium/armoured/5/swarm/21")
	assert_eq(RaidDigests.wave(MonsterLair.new(MonsterDifficulty.Value.EASY, 3)), "easy/null/3/null/0")


func test_writes_a_report_and_a_raid_state() -> void:
	var player := RaidSamples.raid_player({HARPOONIST: 2})
	var fight := FightResult.new(CombatSide.Value.MONSTER, 4, [], [], [], 5, 3)
	var report := RaidReport.new(
		12, false, MonsterLair.new(MonsterDifficulty.Value.EASY, 5), fight, 0, {HARPOONIST: 2},
		{}, {HARPOONIST: 1}, {HARPOONIST: 1}, {}, {ResourceType.Value.CORAL: 300, ResourceType.Value.ORE: 3},
	)
	assert_eq(RaidDigests.report(report), "12 L 1 1 0 303 4")
	player.raid_state.add_noise(7)
	assert_eq(
		RaidDigests.raid_state(player),
		"7 7 0 0 0 false | 1000 1000 1000 1000 1000 | 0 2 0 0 0 0",
	)


func test_arms_the_kernels_and_writes_a_wave_on_one_and_its_state() -> void:
	var game := GameSamples.game([GameSamples.player("human"), GameSamples.player("f")])
	RaidDigests.arm_for_volcano(game)
	var human := game.players["human"]
	var faction := game.players["f"]
	assert_eq([KernelGarrison.kernel_level_of(human), KernelGarrison.kernel_level_of(faction)], [3, 2])
	assert_eq(KernelGarrison.of(human), {UnitType.Value.GUARDIAN: 12, UnitType.Value.DOME_BREAKER: 20})
	assert_eq(KernelGarrison.of(faction), {UnitType.Value.GUARDIAN: 4})
	var fight := FightResult.new(CombatSide.Value.PLAYER, 3, [], [], [], 5, 0)
	var report := VolcanoReport.new(
		7, true, VolcanoWaveFactory.from_kernel_level(3), fight, 3, {}, {}, {HARPOONIST: 2}, {HARPOONIST: 1}
	)
	assert_eq(RaidDigests.volcano_report(report), "7 V 3 6 1 2 3")
	assert_eq(RaidDigests.volcano_state(faction), "0 0 false null 2 | 0 0 4 0 0 0 | 0 0")
	faction.volcano_state.announce(report.wave, 8)
	assert_eq(RaidDigests.volcano_state(faction), "0 0 true 8 2 | 0 0 4 0 0 0 | 0 0")

extends TestCase
## test/domain/action/worksite_limits_test.dart: the building sites and the
## laboratory, one task each a turn, freed at its end.


func _scenario(hq_level := 1) -> Player:
	var player := Player.new("Test")
	for resource: GameResource in player.resources.values():
		resource.amount = resource.max_storage
	player.buildings[BuildingType.Value.HEADQUARTERS].level = hq_level
	player.buildings[BuildingType.Value.LABORATORY].level = 2
	player.tech_branches[TechBranch.Value.MILITARY].unlocked = true
	player.tech_branches[TechBranch.Value.RESOURCES].unlocked = true
	return player


func _upgrade(player: Player, type: BuildingType.Value) -> ActionResult:
	return UpgradeBuildingAction.new(type).execute(ActionSamples.game_of(player), player)


func test_a_single_building_site_below_hq_5() -> void:
	var player := _scenario()
	assert_true(_upgrade(player, BuildingType.Value.ALGAE_FARM).is_success)
	var second := _upgrade(player, BuildingType.Value.CORAL_MINE)
	assert_false(second.is_success)
	assert_eq(second.reason, ActionFailure.Value.WORKSITES_BUSY)


func test_two_building_sites_from_hq_5() -> void:
	var player := _scenario(5)
	assert_true(_upgrade(player, BuildingType.Value.ALGAE_FARM).is_success)
	assert_true(_upgrade(player, BuildingType.Value.CORAL_MINE).is_success)
	assert_false(_upgrade(player, BuildingType.Value.SOLAR_PANEL).is_success)


func test_one_research_per_turn() -> void:
	var player := _scenario()
	var game := ActionSamples.game_of(player)
	assert_true(ResearchTechAction.new(TechBranch.Value.MILITARY).execute(game, player).is_success)
	var second := ResearchTechAction.new(TechBranch.Value.RESOURCES).execute(game, player)
	assert_false(second.is_success)
	assert_eq(second.reason, ActionFailure.Value.RESEARCH_ALREADY_STARTED)


func test_the_end_of_the_turn_frees_the_sites_and_the_laboratory() -> void:
	var player := _scenario()
	var game := ActionSamples.game_of(player)
	_upgrade(player, BuildingType.Value.ALGAE_FARM)
	ResearchTechAction.new(TechBranch.Value.MILITARY).execute(game, player)
	PlayerTurnResolver.resolve(player, 1)
	assert_eq(player.worksite.upgrades, 0)
	assert_true(player.worksite.can_research())
	assert_true(_upgrade(player, BuildingType.Value.CORAL_MINE).is_success)
	assert_true(player.resources[ResourceType.Value.CORAL].amount > 0)

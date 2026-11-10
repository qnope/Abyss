extends TestCase
## test/domain/action/worksite_limits_test.dart: the building sites and the
## laboratory, one task each a turn. 'one research per turn' waits for
## ResearchTechAction, 'the end of the turn frees the sites and the
## laboratory' for `turn` (PlayerTurnResolver).


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


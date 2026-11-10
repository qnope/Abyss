extends TestCase
## test/domain/objective/tip/archive_tips_test.dart: the Archives of the
## Trench, each card read through TipCatalog (ObjectiveSamples.applies).
## The group "ancients" is in archive_tips_ancients_test.gd.

const Id := TipId.Value
const SCOUT := UnitType.Value.SCOUT
const ARCHIVES: Array = [Id.ABYSS_LISTENS, Id.RIVAL_COLONIES, Id.ANCIENTS, Id.FORGE_TOWERS, Id.AWAKENING]


func test_archives_the_last_section_of_the_guide_holds_the_five_archive_tips() -> void:
	assert_eq(TipCategory.Value.values()[-1], TipCategory.Value.ARCHIVES)
	var ids: Array = []
	for tip: Tip in TipCatalog.all():
		if tip.category == TipCategory.Value.ARCHIVES:
			ids.append(tip.id)
	assert_eq(ids, ARCHIVES)


func test_archives_open_after_the_gameplay_tips_of_the_same_turn() -> void:
	var game := ObjectiveSamples.objective_game()
	game.human_player().saved_objective_state = ObjectiveState.new([], false, true)
	game.human_player().raid_state.record_outcome(false)
	var pending: Array = []
	for tip: Tip in TipCatalog.pending_for(game, game.human_player()):
		pending.append(tip.id)
	assert_eq(pending, [Id.RAID_REPORT, Id.ABYSS_LISTENS])
	var last: Array = []
	for tip: Tip in TipCatalog.all().slice(-5):
		last.append(tip.id)
	assert_eq(last, ARCHIVES)


func test_abyss_listens_once_a_first_raid_was_fought_won_or_lost() -> void:
	for victory: bool in [true, false]:
		var game := ObjectiveSamples.objective_game()
		assert_false(ObjectiveSamples.applies(game, Id.ABYSS_LISTENS))
		game.human_player().raid_state.record_outcome(victory)
		assert_true(ObjectiveSamples.applies(game, Id.ABYSS_LISTENS))


func test_rival_colonies_once_the_base_of_a_faction_is_revealed() -> void:
	assert_false(ObjectiveSamples.applies(ObjectiveSamples.objective_game(), Id.RIVAL_COLONIES))
	var game := GameFactory.new_game("Nemo", 7, Difficulty.Value.NORMAL, false, 2)
	assert_false(ObjectiveSamples.applies(game, Id.RIVAL_COLONIES))
	var rival := game.players[game.factions()[-1].id()]
	game.human_player().add_revealed_cell(1, GridPosition.new(rival.base_x, rival.base_y))
	assert_true(ObjectiveSamples.applies(game, Id.RIVAL_COLONIES))


func test_forge_towers_once_units_stand_below_the_reef() -> void:
	var game := ObjectiveSamples.objective_game()
	RaidSamples.set_units(game.human_player(), SCOUT, 4)
	RaidSamples.set_units(game.human_player(), SCOUT, 0, 2)
	assert_false(ObjectiveSamples.applies(game, Id.FORGE_TOWERS))
	RaidSamples.set_units(game.human_player(), SCOUT, 1, 2)
	assert_true(ObjectiveSamples.applies(game, Id.FORGE_TOWERS))


func test_forge_towers_not_for_the_garrison_of_the_kernel_alone() -> void:
	var game := RaidSamples.kernel_garrison_game(true, 0, 3)
	assert_false(ObjectiveSamples.applies(game, Id.FORGE_TOWERS))
	RaidSamples.set_units(game.human_player(), SCOUT, 1, 3)
	assert_true(ObjectiveSamples.applies(game, Id.FORGE_TOWERS))


func test_awakening_once_the_kernel_is_taken() -> void:
	var game := RaidSamples.kernel_garrison_game()
	ObjectiveSamples.set_building(game.human_player(), BuildingType.Value.VOLCANIC_KERNEL, 0)
	assert_true(ObjectiveSamples.applies(game, Id.AWAKENING))


func test_awakening_not_before() -> void:
	var game := RaidSamples.kernel_garrison_game(false)
	ObjectiveSamples.set_building(game.human_player(), BuildingType.Value.VOLCANIC_KERNEL, 0)
	assert_false(ObjectiveSamples.applies(game, Id.AWAKENING))
	assert_false(ObjectiveSamples.applies(ObjectiveSamples.objective_game(), Id.AWAKENING))


func test_awakening_also_once_taken_then_lost_its_fires_already_lit() -> void:
	var game := RaidSamples.kernel_garrison_game(false)
	assert_true(ObjectiveSamples.applies(game, Id.AWAKENING))

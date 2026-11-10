extends TestCase
## test/domain/objective/tip/archive_tips_test.dart: the Archives of the
## Trench, each card read from its list (ObjectiveSamples.applies). Left
## out: the group "Archives", which reads TipCatalog, and the first two tests
## of "ancients", whose PostWar takes a post through AttackPostAction: both
## wait for `action`.

const Id := TipId.Value
const SCOUT := UnitType.Value.SCOUT


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


func test_ancients_also_for_a_faille_captured_once_then_lost() -> void:
	var game := ObjectiveSamples.objective_game()
	game.human_player().add_history_entry(HistorySamples.capture_entry("cheminee:0"))
	assert_false(ObjectiveSamples.applies(game, Id.ANCIENTS))
	game.human_player().add_history_entry(HistorySamples.capture_entry("faille:1"))
	assert_true(ObjectiveSamples.applies(game, Id.ANCIENTS))


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


## Not in the Dart file, for the tests left: the archives in their order,
## filed last in the Guide; a Faille held, not one held by another, nor a
## Cheminée; other entries of the history and a capture lost are no Faille.
func test_the_archives_in_their_order_and_a_faille_held() -> void:
	var ids: Array = []
	for tip: Tip in ArchiveTips.archive_tips():
		assert_eq(tip.category, TipCategory.Value.ARCHIVES)
		ids.append(tip.id)
	assert_eq(ids, [Id.ABYSS_LISTENS, Id.RIVAL_COLONIES, Id.ANCIENTS, Id.FORGE_TOWERS, Id.AWAKENING])
	assert_eq(TipCategory.Value.values()[-1], TipCategory.Value.ARCHIVES)
	var game := ObjectiveSamples.objective_game()
	game.human_player().add_history_entry(HistorySamples.raid_entry(true))
	var lost := HistorySamples.capture_entry("faille:0")
	lost.captured = false
	game.human_player().add_history_entry(lost)
	_hold(game, TransitionBaseType.Value.FAILLE, "rival")
	assert_false(ObjectiveSamples.applies(game, Id.ANCIENTS))
	_hold(game, TransitionBaseType.Value.CHEMINEE, game.human_player_id)
	assert_false(ObjectiveSamples.applies(game, Id.ANCIENTS))
	_hold(game, TransitionBaseType.Value.FAILLE, game.human_player_id)
	assert_true(ObjectiveSamples.applies(game, Id.ANCIENTS))


## A post of `type` at (7, 7) of level 1, held by `by`.
func _hold(game: Game, type: TransitionBaseType.Value, by: String) -> void:
	var base := TransitionBase.new(type, "X", by)
	var cell := MapCell.new(TerrainType.Value.PLAIN, CellContentType.Value.TRANSITION_BASE, null, null, base)
	game.levels[1].set_cell(7, 7, cell)

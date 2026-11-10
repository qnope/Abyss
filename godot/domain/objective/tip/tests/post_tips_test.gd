extends TestCase
## test/domain/objective/tip/post_tips_test.dart: the tips of the posts,
## read through TipCatalog.next_for, every other tip seen.

const Id := TipId.Value
const FAILLE := TransitionBaseType.Value.FAILLE


## Turns the tips on for the human of `game`, every tip but `id` seen.
func _only(game: Game, id: Id) -> Game:
	game.human_player().saved_objective_state = ObjectiveState.new([], false, true)
	for other: Id in Id.values():
		if other != id:
			game.human_player().saved_objective_state.mark_seen(other)
	return game


func _next(game: Game) -> Variant:
	var tip := TipCatalog.next_for(game, game.human_player())
	return null if tip == null else tip.id


func test_files_the_admiral_with_the_map_the_posts_with_the_threats() -> void:
	assert_eq(TipCatalog.by_id(Id.ADMIRAL).category, TipCategory.Value.MAP)
	for id: Id in [Id.POST_DEFENCE, Id.KERNEL_GARRISON, Id.POST_LOST]:
		assert_eq(TipCatalog.by_id(id).category, TipCategory.Value.THREATS, str(id))


func test_admiral_waits_for_an_abyss_admiral() -> void:
	var game := _only(ObjectiveSamples.objective_game(), Id.ADMIRAL)
	ObjectiveSamples.set_building(game.human_player(), BuildingType.Value.BARRACKS, 2)
	assert_null(_next(game))


func test_admiral_opens_once_the_player_owns_one_on_any_level() -> void:
	var game := _only(ObjectiveSamples.objective_game(), Id.ADMIRAL)
	RaidSamples.set_units(game.human_player(), UnitType.Value.ABYSS_ADMIRAL, 1, 2)
	assert_true(PostTipTriggers.admiral(game, game.human_player()))
	assert_eq(_next(game), Id.ADMIRAL)


func test_post_defence_opens_once_the_human_holds_a_post() -> void:
	var war := PostWar.new(FAILLE, 7, true)
	_only(war.game, Id.POST_DEFENCE)
	assert_eq(_next(war.game), Id.POST_DEFENCE)


func test_post_defence_stays_shut_while_another_player_holds_it() -> void:
	var war := PostWar.new(FAILLE)
	_only(war.game, Id.POST_DEFENCE)
	assert_false(PostTipTriggers.post_held(war.game, war.human()))
	assert_null(_next(war.game))


func test_kernel_garrison_opens_once_the_kernel_is_held_and_built() -> void:
	var game := _only(RaidSamples.kernel_garrison_game(), Id.KERNEL_GARRISON)
	assert_eq(_next(game), Id.KERNEL_GARRISON)


func test_kernel_garrison_waits_for_the_kernel_building() -> void:
	var game := _only(RaidSamples.kernel_garrison_game(), Id.KERNEL_GARRISON)
	ObjectiveSamples.set_building(game.human_player(), BuildingType.Value.VOLCANIC_KERNEL, 0)
	assert_null(_next(game))


func test_kernel_garrison_waits_for_the_kernel_to_be_taken() -> void:
	var game := _only(RaidSamples.kernel_garrison_game(false), Id.KERNEL_GARRISON)
	assert_null(_next(game))


func _with_entry(victory: bool, defending: bool, post: Variant = null) -> Game:
	var game := _only(ObjectiveSamples.objective_game(), Id.POST_LOST)
	var entry := HistorySamples.base_assault_entry(victory, defending)
	entry.post_name = post
	game.human_player().add_history_entry(entry)
	return game


func test_post_lost_opens_once_a_post_of_the_player_was_taken() -> void:
	assert_eq(_next(_with_entry(true, true, "faille:0")), Id.POST_LOST)


func test_post_lost_not_for_a_post_that_held() -> void:
	assert_null(_next(_with_entry(false, true, "faille:0")))


func test_post_lost_not_for_a_post_the_player_took() -> void:
	assert_null(_next(_with_entry(true, false, "faille:0")))


func test_post_lost_not_for_the_base_nor_the_kernel() -> void:
	assert_null(_next(_with_entry(true, true)))
	assert_null(_next(_with_entry(true, true, AttackHeldKernelAction.KERNEL_CODE)))


## Not in the Dart file: another entry of the history is no post lost.
func test_post_lost_not_for_another_entry() -> void:
	var game := _only(ObjectiveSamples.objective_game(), Id.POST_LOST)
	game.human_player().add_history_entry(HistorySamples.raid_entry(false))
	assert_null(_next(game))

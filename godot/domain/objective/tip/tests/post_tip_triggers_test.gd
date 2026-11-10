extends TestCase
## Not in the Dart files: post_tips_test.dart reads the triggers of the posts
## through TipCatalog.nextFor and takes its posts through AttackPostAction,
## and faction_attack_tip_test.dart through AnnounceAttackAction: both wait
## for `action`. The same situations, read from the triggers themselves.

const ADMIRAL := UnitType.Value.ABYSS_ADMIRAL


func test_admiral_waits_for_an_abyss_admiral() -> void:
	var game := ObjectiveSamples.objective_game()
	ObjectiveSamples.set_building(game.human_player(), BuildingType.Value.BARRACKS, 2)
	assert_false(PostTipTriggers.admiral(game, game.human_player()))


func test_admiral_opens_once_the_player_owns_one_on_any_level() -> void:
	var game := ObjectiveSamples.objective_game()
	RaidSamples.set_units(game.human_player(), ADMIRAL, 0)
	assert_false(PostTipTriggers.admiral(game, game.human_player()))
	RaidSamples.set_units(game.human_player(), ADMIRAL, 1, 2)
	assert_true(PostTipTriggers.admiral(game, game.human_player()))


func test_post_defence_opens_once_the_human_holds_a_post_not_another() -> void:
	var game := ObjectiveSamples.objective_game()
	game.levels[2] = ObjectiveSamples.plain_map()
	_hold(game, 2, "rival")
	assert_false(PostTipTriggers.post_held(game, game.human_player()))
	_hold(game, 2, game.human_player_id)
	assert_true(PostTipTriggers.post_held(game, game.human_player()))


func test_kernel_garrison_opens_once_the_kernel_is_held_and_built() -> void:
	var game := RaidSamples.kernel_garrison_game()
	assert_true(PostTipTriggers.kernel_garrison(game, game.human_player()))
	ObjectiveSamples.set_building(game.human_player(), BuildingType.Value.VOLCANIC_KERNEL, 0)
	assert_false(PostTipTriggers.kernel_garrison(game, game.human_player()))
	game = RaidSamples.kernel_garrison_game(false)
	assert_false(PostTipTriggers.kernel_garrison(game, game.human_player()))


func test_faction_attack_opens_after_the_first_attack_on_the_base() -> void:
	var game := ObjectiveSamples.objective_game()
	assert_false(ObjectiveSamples.applies(game, TipId.Value.FACTION_ATTACK))
	game.human_player().add_history_entry(HistorySamples.base_assault_entry(true, false))
	assert_false(ObjectiveSamples.applies(game, TipId.Value.FACTION_ATTACK))
	var on_post := HistorySamples.base_assault_entry(true, true)
	on_post.post_name = "Faille Beta"
	game.human_player().add_history_entry(on_post)
	assert_false(ObjectiveSamples.applies(game, TipId.Value.FACTION_ATTACK))
	game.human_player().add_history_entry(HistorySamples.base_assault_entry(true, true))
	assert_true(ObjectiveSamples.applies(game, TipId.Value.FACTION_ATTACK))


## A Faille at (7, 7) of `level`, held by `by`.
func _hold(game: Game, level: int, by: String) -> void:
	var base := TransitionBase.new(TransitionBaseType.Value.FAILLE, "X", by)
	var cell := MapCell.new(TerrainType.Value.PLAIN, CellContentType.Value.TRANSITION_BASE, null, null, base)
	game.levels[level].set_cell(7, 7, cell)

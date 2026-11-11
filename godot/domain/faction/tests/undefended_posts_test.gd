extends TestCase
## test/domain/faction/undefended_posts_test.dart: the posts a player holds
## with nobody to defend them.

const FAILLE := TransitionBaseType.Value.FAILLE
const CHEMINEE := TransitionBaseType.Value.CHEMINEE


static func _of(war: PostWar) -> Array[TransitionBase]:
	return UndefendedPosts.of(war.game, war.human())


func test_a_faille_with_no_unit_on_level_2_is_undefended() -> void:
	var war := PostWar.new(FAILLE, 7, true)
	assert_eq(_of(war), [war.post])


func test_a_cheminee_with_no_unit_on_level_3_is_undefended() -> void:
	var war := PostWar.new(CHEMINEE, 7, true)
	assert_eq(_of(war), [war.post])


func test_a_single_unit_on_the_level_below_defends_the_post() -> void:
	var war := PostWar.new(FAILLE, 7, true)
	war.put(war.human(), 2, {UnitType.Value.HARPOONIST: 1})
	assert_eq(_of(war), [])


func test_units_on_another_level_do_not_defend_the_post() -> void:
	var war := PostWar.new(FAILLE, 7, true)
	war.put(war.human(), 1, PostWar.GARRISON)
	war.put(war.human(), 3, PostWar.GARRISON)
	assert_eq(_of(war), [war.post])


func test_a_post_whose_passage_is_at_level_0_is_not_listed_nobody_can_go_down_yet() -> void:
	var war := PostWar.new(FAILLE, 7, true)
	war.human().buildings[war.passage()].level = 0
	assert_eq(_of(war), [])


func test_a_post_held_by_someone_else_is_not_the_players_concern() -> void:
	var war := PostWar.new(FAILLE)
	assert_eq(_of(war), [])


func test_no_post_held_nothing_undefended() -> void:
	var war := PostWar.new(FAILLE, 7, true)
	war.post.captured_by = null
	assert_eq(_of(war), [])


func test_both_posts_undefended_are_listed_the_faille_first() -> void:
	var war := PostWar.new(CHEMINEE, 7, true)
	var rift := PostWar.new(FAILLE).at  # Same map seed.
	var faille: TransitionBase = war.game.levels[1].cell_at(rift.x, rift.y).transition_base
	faille.captured_by = war.human().id
	war.human().buildings[BuildingType.Value.DESCENT_MODULE] = Building.new(
		BuildingType.Value.DESCENT_MODULE, 1
	)
	assert_eq(_of(war), [faille, war.post])

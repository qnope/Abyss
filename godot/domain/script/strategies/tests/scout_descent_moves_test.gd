extends TestCase
## test/domain/script/strategies/scout_descent_moves_test.dart: the scouts
## sent down ahead of the army through the posts the faction holds.

const FAILLE := TransitionBaseType.Value.FAILLE
const BOTH: Array[TransitionBaseType.Value] = [FAILLE, TransitionBaseType.Value.CHEMINEE]


func _holding(posts: Array[TransitionBaseType.Value], home := 10) -> DeepScouts:
	var deep := DeepScouts.new()
	for kind: TransitionBaseType.Value in posts:
		deep.hold(kind)
	deep.put(1, home)
	return deep


func test_deepest_reachable_is_the_base_level_without_a_faille() -> void:
	assert_eq(ScoutDescentMoves.deepest_reachable(DeepScouts.new().turn()), 1)


func test_deepest_reachable_goes_one_level_down_per_held_post_with_its_passage() -> void:
	assert_eq(ScoutDescentMoves.deepest_reachable(_holding([FAILLE]).turn()), 2)
	assert_eq(ScoutDescentMoves.deepest_reachable(_holding(BOTH).turn()), 3)


func test_send_scouts_down_takes_scouts_from_the_base_to_level_3_in_the_same_turn() -> void:
	var deep := _holding(BOTH)
	ScoutDescentMoves.send_scouts_down(deep.turn(), 6)
	assert_eq(deep.scouts(3), 6)
	assert_eq(deep.scouts(2), 0)
	assert_eq(deep.scouts(1), 4)


func test_send_scouts_down_stops_at_level_2_while_only_the_faille_is_held() -> void:
	var deep := _holding([FAILLE])
	ScoutDescentMoves.send_scouts_down(deep.turn(), 6)
	assert_eq(deep.scouts(2), 6)
	assert_eq(deep.scouts(1), 4)


func test_send_scouts_down_only_tops_the_deep_level_up() -> void:
	var deep := _holding(BOTH)
	deep.put(3, 4)
	deep.put(2, 1)
	ScoutDescentMoves.send_scouts_down(deep.turn(), 6)
	assert_eq(deep.scouts(3), 6)
	assert_eq(deep.scouts(2), 0, "the scout on the way goes first")
	assert_eq(deep.scouts(1), 9)


func test_send_scouts_down_sends_nothing_when_the_deep_level_has_enough() -> void:
	var deep := _holding(BOTH)
	deep.put(3, 6)
	ScoutDescentMoves.send_scouts_down(deep.turn(), 6)
	assert_eq(deep.scouts(1), 10)


func test_once_the_road_is_seen_there_no_scout_goes_ahead_to_a_volcano_already_seen() -> void:
	var deep := _holding(BOTH)
	deep.faction().add_revealed_cell(3, deep.kernel()[0])
	ScoutDescentMoves.send_scouts_down(deep.turn(), 6)
	assert_eq(deep.scouts(3), 0)
	assert_eq(ScoutDescentMoves.scouts_missing_below(deep.turn(), 6), 0)


func test_once_the_road_is_seen_there_nor_to_a_level_2_whose_cheminee_is_seen() -> void:
	var deep := _holding([FAILLE])
	var cheminee := deep.cells(2, func(c: MapCell) -> bool:
		return c.transition_base != null and c.transition_base.type == TransitionBaseType.Value.CHEMINEE)
	deep.faction().add_revealed_cell(2, cheminee[0])
	deep.put(2, 0)
	ScoutDescentMoves.send_scouts_down(deep.turn(), 6)
	assert_eq(deep.scouts(2), 0)


func test_scouts_wanted_keeps_the_expedition_scouts_home_for_the_army() -> void:
	var deep := _holding(BOTH)
	deep.put(3, 4)
	assert_eq(ScoutMoves.scouts_wanted(deep.turn(), 2, 6), 8)


func test_scouts_wanted_ahead_of_the_army_only_what_is_missing_below() -> void:
	var deep := _holding(BOTH)
	deep.put(3, 4)
	var turn := deep.turn()
	assert_eq(ScoutMoves.scouts_wanted(turn, 2, 6, true), 4)
	assert_eq(ScoutDescentMoves.scouts_missing_below(turn, 6), 2)


func test_scout_sends_scouts_down_ahead_of_the_army_when_asked() -> void:
	var deep := _holding(BOTH)
	ScoutMoves.scout(deep.turn(), 2, 6, 2, true)
	assert_eq(deep.scouts(3) + deep.targets(3).size(), 6)


func test_scout_keeps_them_home_otherwise() -> void:
	var deep := _holding(BOTH)
	ScoutMoves.scout(deep.turn(), 2, 6)
	assert_eq(deep.scouts(3), 0)


## Not in the Dart file: a degraded passage closes the road, a base level
## without scouts sends none, and the scouts missing at the base.
func test_a_degraded_passage_closes_the_road_and_an_empty_base_sends_nobody() -> void:
	var deep := _holding([FAILLE])
	deep.faction().buildings[BuildingType.Value.HEADQUARTERS].level = 1
	deep.faction().buildings[BuildingType.Value.DESCENT_MODULE].level = 5
	assert_true(deep.faction().is_degraded(BuildingType.Value.DESCENT_MODULE))
	assert_eq(ScoutDescentMoves.deepest_reachable(deep.turn()), 1)
	ScoutDescentMoves.send_scouts_down(deep.turn(), 6)
	assert_eq(deep.scouts(1), 10)
	var empty := _holding(BOTH, 0)
	ScoutDescentMoves.send_scouts_down(empty.turn(), 6)
	assert_eq(empty.scouts(3), 0)
	assert_eq(ScoutDescentMoves.scouts_missing_below(empty.turn(), 6), 6)


## Not in the Dart file: more scouts below than wanted leave none missing.
func test_no_scout_is_missing_when_more_than_wanted_stand_below() -> void:
	var deep := _holding(BOTH)
	deep.put(3, 8)
	assert_eq(ScoutDescentMoves.scouts_missing_below(deep.turn(), 6), 0)

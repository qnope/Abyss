extends TestCase
## test/domain/map/post_holder_test.dart: who holds a Faille or a Cheminée,
## as the human sees it.

const Holder := PostHolder.Value


func test_of_a_base_nobody_captured_is_still_guarded() -> void:
	assert_eq(PostHolder.of(_base(), "human"), Holder.GUARDIANS)


func test_of_a_base_the_human_captured_is_theirs() -> void:
	assert_eq(PostHolder.of(_base("human"), "human"), Holder.HUMAN)


func test_of_a_base_another_player_captured_is_a_faction_s() -> void:
	assert_eq(PostHolder.of(_base("murenes"), "human"), Holder.FACTION)


func test_passages_below_gives_the_holder_of_each_base_where_its_passage_lies_below() -> void:
	var holders := PostHolder.passages_below(_above(), "human")
	assert_eq(holders, {Vector2i(2, 1): Holder.FACTION})


func test_passages_below_is_empty_without_a_level_above() -> void:
	assert_eq(PostHolder.passages_below(null, "human"), {})


## Not in the Dart file: the names the presentation reads, and the holders
## of several posts in the order of the grid.
func test_has_the_values_of_dart_in_its_order() -> void:
	assert_eq(DartEnum.names(Holder), PackedStringArray(["guardians", "human", "faction"]))
	var above := _above()
	above.set_cell(0, 0, _post_cell(_base("human")))
	above.set_cell(1, 2, _post_cell(_base()))
	var holders := PostHolder.passages_below(above, "human")
	assert_eq(holders.keys(), [Vector2i(0, 0), Vector2i(2, 1), Vector2i(1, 2)])
	assert_eq(holders.values(), [Holder.HUMAN, Holder.FACTION, Holder.GUARDIANS])


func _base(captured_by: Variant = null) -> TransitionBase:
	return TransitionBase.new(TransitionBaseType.Value.FAILLE, "faille:0", captured_by)


func _post_cell(base: TransitionBase) -> MapCell:
	return MapCell.new(
		TerrainType.Value.PLAIN, CellContentType.Value.TRANSITION_BASE, null, null, base
	)


func _above() -> GameMap:
	var map := MapSamples.plain_map(3, 3)
	map.set_cell(2, 1, _post_cell(_base("murenes")))
	return map

extends TestCase
## test/domain/map/map_cell_test.dart: one cell of a map and `copyWith`,
## which tells a field left as it is from a field set to null.

const PLAIN := TerrainType.Value.PLAIN
const EMPTY := CellContentType.Value.EMPTY
const RUINS := CellContentType.Value.RUINS
const LAIR := CellContentType.Value.MONSTER_LAIR
const EASY := MonsterDifficulty.Value.EASY
const HARD := MonsterDifficulty.Value.HARD


func test_defaults_default_collected_by_is_null_and_is_collected_is_false() -> void:
	var cell := MapCell.new(PLAIN)
	assert_null(cell.collected_by)
	assert_false(cell.is_collected())


func test_defaults_default_content_is_empty_and_lair_is_null() -> void:
	var cell := MapCell.new(PLAIN)
	assert_eq(cell.terrain, PLAIN)
	assert_eq(cell.content, EMPTY)
	assert_null(cell.lair)


func test_defaults_full_construction_with_all_fields() -> void:
	var cell := MapCell.new(PLAIN, LAIR, MonsterLair.new(HARD, 150), "uuid-a")
	assert_eq(cell.terrain, PLAIN)
	assert_eq(cell.content, LAIR)
	assert_eq(cell.lair.difficulty, HARD)
	assert_eq(cell.lair.unit_count, 150)
	assert_eq(cell.collected_by, "uuid-a")
	assert_true(cell.is_collected())


func test_copy_with_collected_by_value_sets_collected_by() -> void:
	var cell := MapCell.new(PLAIN)
	var collected := cell.copy_with({"collected_by": "uuid-a"})
	assert_eq(collected.collected_by, "uuid-a")
	assert_true(collected.is_collected())


func test_copy_with_no_args_preserves_collected_by_and_lair() -> void:
	var cell := MapCell.new(PLAIN, LAIR, MonsterLair.new(EASY, 25), "uuid-a")
	var copy := cell.copy_with()
	assert_eq(copy.collected_by, "uuid-a")
	assert_eq(copy.lair.difficulty, EASY)
	assert_eq(copy.lair.unit_count, 25)


func test_copy_with_content_preserves_existing_collected_by() -> void:
	var cell := MapCell.new(PLAIN, EMPTY, null, "uuid-a")
	var copy := cell.copy_with({"content": RUINS})
	assert_eq(copy.collected_by, "uuid-a")
	assert_eq(copy.content, RUINS)


func test_copy_with_collected_by_null_clears_the_value_via_sentinel() -> void:
	var cell := MapCell.new(PLAIN, EMPTY, null, "uuid-a")
	var cleared := cell.copy_with({"collected_by": null})
	assert_null(cleared.collected_by)
	assert_false(cleared.is_collected())


func test_copy_with_lair_value_replaces_lair() -> void:
	var cell := MapCell.new(PLAIN, LAIR, MonsterLair.new(EASY, 25))
	var updated := cell.copy_with({"lair": MonsterLair.new(HARD, 200)})
	assert_eq(updated.lair.difficulty, HARD)
	assert_eq(updated.lair.unit_count, 200)


func test_copy_with_lair_null_clears_the_lair_via_sentinel() -> void:
	var cell := MapCell.new(PLAIN, LAIR, MonsterLair.new(MonsterDifficulty.Value.MEDIUM, 75))
	var cleared := cell.copy_with({"lair": null})
	assert_null(cleared.lair)


func test_copy_with_overrides_other_fields_independently() -> void:
	var cell := MapCell.new(PLAIN)
	var updated := cell.copy_with({"content": LAIR, "lair": MonsterLair.new(EASY, 30)})
	assert_eq(updated.terrain, PLAIN)
	assert_eq(updated.content, LAIR)
	assert_eq(updated.lair.difficulty, EASY)
	assert_null(updated.collected_by)


## Not in the Dart file: the post and the passage name, set, kept and
## cleared as the lair is, and the cell copied left as it was.
func test_copy_with_sets_keeps_and_clears_the_post_and_the_passage_name() -> void:
	var post := TransitionBase.new(TransitionBaseType.Value.FAILLE, "faille:0")
	var cell := MapCell.new(PLAIN, EMPTY, null, null, post, "faille:2")
	assert_eq(cell.transition_base, post)
	assert_eq(cell.passage_name, "faille:2")
	var kept := cell.copy_with({"content": RUINS})
	assert_eq(kept.transition_base, post, "the same post, as in Dart")
	assert_eq(kept.passage_name, "faille:2")
	var cleared := cell.copy_with({"transition_base": null, "passage_name": null})
	assert_null(cleared.transition_base)
	assert_null(cleared.passage_name)
	var named := cleared.copy_with({"transition_base": post, "passage_name": "faille:3"})
	assert_eq(named.transition_base, post)
	assert_eq(named.passage_name, "faille:3")
	assert_eq(cell.content, EMPTY)
	assert_eq(cell.passage_name, "faille:2")


## Not in the Dart file: Dart's `terrain ?? this.terrain` and `content ??
## this.content` keep the field when given null, where the four others
## become null.
func test_copy_with_a_null_terrain_or_content_keeps_the_field() -> void:
	var cell := MapCell.new(PLAIN, RUINS)
	var copy := cell.copy_with({"terrain": null, "content": null})
	assert_eq(copy.terrain, PLAIN)
	assert_eq(copy.content, RUINS)
	assert_eq(cell.copy_with({"terrain": PLAIN}).terrain, PLAIN)


## Not in the Dart file: Dart refuses to compile a field that does not exist.
func test_copy_with_refuses_a_field_a_cell_does_not_have() -> void:
	expect_error('MapCell.copy_with: no field "contents"')
	var copy := MapCell.new(PLAIN, RUINS).copy_with({"contents": EMPTY})
	assert_eq(copy.content, RUINS)

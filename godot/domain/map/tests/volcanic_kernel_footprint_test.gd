extends TestCase
## test/domain/map/volcanic_kernel_footprint_test.dart: the four cells the
## volcano covers.

const KERNEL := CellContentType.Value.VOLCANIC_KERNEL
const PART := CellContentType.Value.VOLCANIC_KERNEL_PART
const SIZE := 21


func test_the_kernel_covers_a_2x2_footprint_anchored_on_the_centre() -> void:
	var cells := MapSamples.plain_cells(SIZE * SIZE)
	VolcanicKernelPlacer.place(cells, SIZE, SIZE)

	assert_eq(cells[10 * SIZE + 10].content, KERNEL)
	for i: int in [10 * SIZE + 11, 11 * SIZE + 10, 11 * SIZE + 11]:
		assert_eq(cells[i].content, PART)
	var covered := MapSamples.indices_of(cells, KERNEL) + MapSamples.indices_of(cells, PART)
	assert_eq(covered.size(), 4)


func test_the_footprint_wipes_lairs_and_transition_bases_it_lands_on() -> void:
	var cells := MapSamples.plain_cells(SIZE * SIZE)
	cells[11 * SIZE + 11] = cells[11 * SIZE + 11].copy_with(
		{"content": CellContentType.Value.MONSTER_LAIR}
	)
	VolcanicKernelPlacer.place(cells, SIZE, SIZE)

	assert_eq(cells[11 * SIZE + 11].content, PART)
	assert_null(cells[11 * SIZE + 11].lair)


func test_footprint_lists_the_four_cells_anchor_first() -> void:
	assert_eq(
		VolcanicKernelPlacer.footprint(10, 10),
		[Vector2i(10, 10), Vector2i(11, 10), Vector2i(10, 11), Vector2i(11, 11)]
	)


## Not in the Dart file: the lair and the post themselves are wiped, which
## the Dart test only checks on a cell that had none.
func test_the_footprint_leaves_no_stale_lair_nor_post_under_the_volcano() -> void:
	var cells := MapSamples.plain_cells(SIZE * SIZE)
	var lair := MonsterLair.new(MonsterDifficulty.Value.HARD, 150)
	var post := TransitionBase.new(TransitionBaseType.Value.FAILLE, "faille:0")
	cells[10 * SIZE + 10] = cells[10 * SIZE + 10].copy_with({"lair": lair, "passage_name": "p"})
	cells[10 * SIZE + 11] = cells[10 * SIZE + 11].copy_with({"transition_base": post})
	VolcanicKernelPlacer.place(cells, SIZE, SIZE)

	assert_null(cells[10 * SIZE + 10].lair)
	assert_eq(cells[10 * SIZE + 10].passage_name, "p", "the passage name stays")
	assert_null(cells[10 * SIZE + 11].transition_base)

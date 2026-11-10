extends TestCase
## The lairs a map keeps, forces and trims, and the cells left bare around
## the other bases. Not in the Dart file (content_placer_test.dart): the
## generated maps of the vectors hold all of it, cell by cell; these say
## which rule each cell follows.

const EMPTY := CellContentType.Value.EMPTY
const LAIR := CellContentType.Value.MONSTER_LAIR


## A lair trimmed past the most a map holds has drawn its dice: its cell is
## empty again and keeps the lair, as `MapCell.copyWith` does in Dart.
func test_a_trimmed_lair_stays_under_the_empty_content_of_its_cell() -> void:
	var kept := _placed(7, {}, [], 5, 10)
	var none := _placed(7, {}, [], 0, 0)
	assert_eq(MapSamples.indices_of(none, LAIR), [])
	var stale := 0
	for index: int in none.size():
		assert_eq(none[index].lair == null, kept[index].lair == null, "cell %d" % index)
		if none[index].lair != null:
			stale += 1
			assert_eq(none[index].content, EMPTY)
			assert_eq(none[index].lair.unit_count, kept[index].lair.unit_count)
	assert_true(stale > 10, "%d lairs rolled" % stale)


func test_a_map_with_too_few_lairs_forces_more_on_empty_cells() -> void:
	var cells := _placed(7, {}, [], 60, 60)
	assert_eq(MapSamples.indices_of(cells, LAIR).size(), 60)


## Every cell is within 2 cells of the base: nothing can hold a lair.
func test_a_map_without_any_free_cell_forces_none() -> void:
	var cells := MapSamples.plain_cells(5 * 5)
	var random := DartRandom.new(1)
	ContentPlacer.place(cells, 5, 5, 2, 2, random)
	assert_eq(MapSamples.contents(cells).count(EMPTY), 25)
	assert_eq(random.next_int(1000), DartRandom.new(1).next_int(1000), "no die drawn")


func test_nothing_is_placed_within_2_cells_of_another_base() -> void:
	var others: Array[GridPosition] = [GridPosition.new(3, 3), GridPosition.new(17, 15)]
	for seed_of_map: int in 10:
		var cells := _placed(seed_of_map, {}, others, 5, 10)
		for base: GridPosition in others:
			for y: int in range(base.y - 2, base.y + 3):
				for x: int in range(base.x - 2, base.x + 3):
					assert_eq(cells[y * 20 + x].content, EMPTY, "(%d,%d)" % [x, y])
					assert_null(cells[y * 20 + x].lair)


## The first third of each band of the roll still places something: a map
## holds about half as many ruins as treasures, and lairs on a tenth of its
## cells before they are trimmed.
func test_a_roll_places_a_treasure_ruins_a_lair_or_nothing() -> void:
	var counts: Dictionary[CellContentType.Value, int] = {}
	for seed_of_map: int in 40:
		var cells_of_map := _placed(seed_of_map, {}, [], 0, 400)
		for content: CellContentType.Value in MapSamples.contents(cells_of_map):
			counts[content] = counts.get(content, 0) + 1
	var cells := 40 * (400 - 25)
	assert_eq(counts.keys().size(), 4)
	assert_almost_eq(counts[CellContentType.Value.RESOURCE_BONUS] / float(cells), 0.2 / 3, 0.01)
	assert_almost_eq(counts[CellContentType.Value.RUINS] / float(cells), 0.1 / 3, 0.01)
	assert_almost_eq(counts[LAIR] / float(cells), 0.1, 0.01)


## Far from the base, half the lairs are hard; near it, half are easy.
func test_lairs_are_harder_far_from_the_base() -> void:
	var near: Array[int] = [0, 0, 0]
	var far: Array[int] = [0, 0, 0]
	for seed_of_map: int in 60:
		var cells := _placed(seed_of_map, {}, [], 0, 400)
		for index: int in MapSamples.indices_of(cells, LAIR):
			var apart := MapSamples.chebyshev(index % 20, DartMath.trunc_div(index, 20), 10, 10)
			var tally := far if apart > 7 else near
			tally[cells[index].lair.difficulty] += 1
	assert_true(near[0] > near[1] and near[1] > near[2], str(near))
	assert_true(far[2] > far[1] and far[1] > far[0], str(far))


func _placed(
	seed_of_map: int,
	reserved: Dictionary[int, bool],
	others: Array[GridPosition],
	min_lairs: int,
	max_lairs: int,
) -> Array[MapCell]:
	var cells := MapSamples.plain_cells(20 * 20)
	ContentPlacer.place(
		cells, 20, 20, 10, 10, DartRandom.new(seed_of_map), reserved, 0, others,
		min_lairs, max_lairs,
	)
	return cells

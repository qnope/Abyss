extends TestCase
## test/domain/objective/guide/guide_target_cell_test.dart: a cell of the map
## surrounded by the halo, or the kernel and its garrison button.

var cell := GridPosition.new(3, 4)


func test_a_cell_target_surrounds_one_cell_of_one_level_of_the_map() -> void:
	var target := GuideTarget.for_cell(2, cell)
	assert_eq(target.area, GuideArea.Value.MAP)
	assert_eq(target.level, 2)
	assert_true(target.is_cell(2, 3, 4))
	assert_false(target.is_cell(1, 3, 4))
	assert_false(target.is_cell(2, 4, 3))
	assert_false(target.garrison)
	assert_false(target.is_building(BuildingType.Value.BARRACKS))


func test_the_map_alone_surrounds_no_cell() -> void:
	var target := GuideTarget.for_map()
	assert_null(target.level)
	assert_false(target.is_cell(1, 3, 4))


func test_a_garrison_target_surrounds_the_kernel_and_its_garrison_button() -> void:
	var target := GuideTarget.for_garrison(3, cell)
	assert_eq(target.area, GuideArea.Value.MAP)
	assert_true(target.is_cell(3, 3, 4))
	assert_true(target.garrison)


func test_cell_targets_compare_by_level_cell_and_garrison() -> void:
	assert_true(GuideTarget.for_cell(2, cell).equals(GuideTarget.for_cell(2, GridPosition.new(3, 4))))
	assert_eq(GuideTarget.for_cell(2, cell).hash_code(), GuideTarget.for_cell(2, GridPosition.new(3, 4)).hash_code())
	assert_false(GuideTarget.for_cell(2, cell).equals(GuideTarget.for_cell(1, cell)))
	assert_false(GuideTarget.for_cell(3, cell).equals(GuideTarget.for_garrison(3, cell)))
	assert_false(GuideTarget.for_cell(2, cell).equals(GuideTarget.for_map()))
	assert_true(str(GuideTarget.for_cell(2, cell)).contains("2"))


## Not in the Dart file: two cells of the same level told apart.
func test_two_cells_of_a_level_differ() -> void:
	assert_false(GuideTarget.for_cell(2, cell).equals(GuideTarget.for_cell(2, GridPosition.new(4, 3))))

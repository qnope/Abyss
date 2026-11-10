extends TestCase
## test/domain/map/cell_content_type_test.dart: what a cell of a map holds.

const Type := CellContentType.Value


func test_cell_content_type_has_all_9_values() -> void:
	assert_eq(Type.size(), 9)
	assert_has(Type.values(), Type.EMPTY)
	assert_has(Type.values(), Type.RESOURCE_BONUS)
	assert_has(Type.values(), Type.RUINS)
	assert_has(Type.values(), Type.MONSTER_LAIR)
	assert_has(Type.values(), Type.TRANSITION_BASE)
	assert_has(Type.values(), Type.PASSAGE)
	assert_has(Type.values(), Type.VOLCANIC_KERNEL)


func test_cell_content_type_values_have_correct_indices() -> void:
	assert_eq(Type.EMPTY, 0)
	assert_eq(Type.RESOURCE_BONUS, 1)
	assert_eq(Type.RUINS, 2)
	assert_eq(Type.MONSTER_LAIR, 3)


func test_cell_content_type_volcanic_kernel_exists() -> void:
	assert_eq(Type.VOLCANIC_KERNEL, 6)


func test_cell_content_type_the_wreck_comes_last_after_every_saved_value() -> void:
	assert_eq(Type.WRECK, 7)


func test_cell_content_type_the_volcano_footprint_part_is_appended_without_moving_others() -> void:
	assert_eq(Type.VOLCANIC_KERNEL_PART, 8)


## Not in the Dart file: the names the snapshots and the vectors write.
func test_has_the_values_of_dart_in_its_order() -> void:
	assert_eq(DartEnum.names(Type), PackedStringArray([
		"empty", "resourceBonus", "ruins", "monsterLair", "transitionBase", "passage",
		"volcanicKernel", "wreck", "volcanicKernelPart",
	]))

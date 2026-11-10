extends TestCase
## test/domain/map/volcanic_kernel_placer_test.dart: where the volcano
## stands.

const KERNEL := CellContentType.Value.VOLCANIC_KERNEL


func test_place_places_volcanic_kernel_at_center_index_210_on_20x20() -> void:
	var cells := _placed()
	assert_eq(cells[210].content, KERNEL)


func test_place_center_cell_10_10_has_volcanic_kernel_content() -> void:
	var cells := _placed()
	var center_x := DartMath.trunc_div(20, 2)
	var center_y := DartMath.trunc_div(20, 2)
	assert_eq(cells[center_y * 20 + center_x].content, KERNEL)


func test_place_only_one_cell_has_volcanic_kernel_content() -> void:
	var cells := _placed()
	assert_eq(MapSamples.indices_of(cells, KERNEL).size(), 1)


func _placed() -> Array[MapCell]:
	var cells := MapSamples.plain_cells(20 * 20)
	VolcanicKernelPlacer.place(cells, 20, 20)
	return cells

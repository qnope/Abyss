extends TestCase
## The head of a board that shows what stands on the cells: the two renders
## of cells.sh, scaled down to the board's width, or nothing without them.

const BoardCells := preload("res://tool/models/board_cells.gd")

var _head: BoardCells


func after_each() -> void:
	if _head != null:
		_head.free()
		_head = null


func test_without_renders_it_is_empty() -> void:
	_head = BoardCells.new("user://board_cells_nothing")
	assert_eq(_head.get_child_count(), 0)


func test_each_render_is_a_caption_over_a_picture_scaled_down_to_the_width() -> void:
	var folder := "user://board_cells_test"
	DirAccess.make_dir_recursive_absolute(folder)
	Image.create(BoardCells.WIDTH * 2, 400, false, Image.FORMAT_RGBA8).save_png(folder + "/cells_near.png")
	Image.create(300, 200, false, Image.FORMAT_RGBA8).save_png(folder + "/cells_far.png")
	_head = BoardCells.new(folder)
	assert_eq(_head.get_child_count(), 4)
	assert_eq((_head.get_child(0) as Label).text, "on the cells, near")
	assert_eq((_head.get_child(1) as TextureRect).custom_minimum_size, Vector2(BoardCells.WIDTH, 200))
	assert_eq((_head.get_child(3) as TextureRect).custom_minimum_size, Vector2(300, 200))
	DirAccess.remove_absolute(folder + "/cells_near.png")
	DirAccess.remove_absolute(folder + "/cells_far.png")

extends TestCase
## A row of the review board: one line of views, or two for a building with
## tiers, and the portrait after the first line.

const BoardRow := preload("res://tool/models/board_row.gd")

var _row: BoardRow


func after_each() -> void:
	if _row != null:
		_row.free()
		_row = null


func test_a_model_without_tiers_has_one_line_of_views() -> void:
	assert_eq(BoardRow.views(0).size(), 1)
	assert_eq(BoardRow.views(1).size(), 1)
	assert_eq(BoardRow.views(0)[0], BoardRow.VIEWS)


func test_a_model_with_tiers_shows_its_game_and_close_views_at_each_tier() -> void:
	var lines := BoardRow.views(3)
	assert_eq(lines.size(), 2)
	assert_eq(lines[0], ["t1_game", "t2_game", "game", "front", "right"])
	assert_eq(lines[1], ["t1_close", "t2_close", "close", "back", "left"])


func test_captions_say_which_tiers_a_view_shows() -> void:
	assert_eq(BoardRow._caption("game"), "game")
	assert_eq(BoardRow._caption("t1_close"), "close, tier 1")
	assert_eq(BoardRow._caption("t2_game"), "game, tiers 1-2")


func test_a_creature_has_no_close_view() -> void:
	assert_eq(BoardRow.views(0, true), [BoardRow.CREATURE] as Array[Array])
	assert_false(BoardRow.CREATURE.has("close"))
	assert_eq(BoardRow.POSES.size(), 2)
	assert_eq(BoardRow.POSES[1], ["attack_0", "attack_1", "attack_2", "hit_0", "hit_1", "hit_2"])


func test_captions_number_the_poses_of_an_action() -> void:
	assert_eq(BoardRow._caption("swim_0"), "swim 1/3")
	assert_eq(BoardRow._caption("attack_2"), "attack 3/3")


func test_a_creature_adds_its_phone_view_and_two_lines_of_poses() -> void:
	var folder := "user://board_row_creature_test"
	DirAccess.make_dir_recursive_absolute(folder)
	var image := Image.create(8, 4, false, Image.FORMAT_RGBA8)
	var files: Array[String] = ["x", "x_phone"]
	for view: Array in BoardRow.views(0, true) + BoardRow.POSES:
		for name_: String in view:
			files.append("x_" + name_)
	for file in files:
		image.save_png("%s/%s.png" % [folder, file])
	_row = BoardRow.new(ProjectSettings.globalize_path(folder), "x", PackedStringArray(["one"]), 0, true)
	# Three lines of pictures, then the name and one line of figures.
	assert_eq(_row.get_child_count(), 5)
	# The views, the portrait and the phone view; then six poses a line.
	assert_eq((_row.get_child(0) as Control).get_child_count(), 7)
	assert_eq((_row.get_child(1) as Control).get_child_count(), 6)
	assert_eq((_row.get_child(2) as Control).get_child_count(), 6)
	for file in DirAccess.get_files_at(folder):
		DirAccess.remove_absolute("%s/%s" % [ProjectSettings.globalize_path(folder), file])
	DirAccess.remove_absolute(ProjectSettings.globalize_path(folder))


func test_builds_its_lines_then_its_name_and_figures() -> void:
	var folder := "user://board_row_test"
	DirAccess.make_dir_recursive_absolute(folder)
	var image := Image.create(8, 4, false, Image.FORMAT_RGBA8)
	for file: String in ["x_t1_game", "x_t2_game", "x_game", "x_front", "x_right", "x_t1_close", "x_t2_close", "x_close", "x_back", "x_left", "x"]:
		image.save_png("%s/%s.png" % [folder, file])
	_row = BoardRow.new(ProjectSettings.globalize_path(folder), "x", PackedStringArray(["one", "two"]), 3)
	assert_eq(_row.get_child_count(), 5)
	assert_eq((_row.get_child(0) as Control).get_child_count(), 6)
	assert_eq((_row.get_child(1) as Control).get_child_count(), 5)
	assert_eq((_row.get_child(2) as Label).text, "x")
	var game := (_row.get_child(0).get_child(0).get_child(0) as TextureRect).texture
	assert_eq(game.get_height(), BoardRow.TILE)
	for file: String in DirAccess.get_files_at(folder):
		DirAccess.remove_absolute("%s/%s" % [ProjectSettings.globalize_path(folder), file])
	DirAccess.remove_absolute(ProjectSettings.globalize_path(folder))


func test_extra_views_make_one_more_line_before_the_name() -> void:
	var folder := "user://board_row_extras_test"
	DirAccess.make_dir_recursive_absolute(folder)
	var image := Image.create(8, 4, false, Image.FORMAT_RGBA8)
	for file: String in ["y_game", "y_front", "y_right", "y_back", "y_left", "y_close", "y_grid", "y_far", "y"]:
		image.save_png("%s/%s.png" % [folder, file])
	_row = BoardRow.new(ProjectSettings.globalize_path(folder), "y", PackedStringArray(["one"]), 0, false,
		PackedStringArray(["grid", "far"]))
	assert_eq(_row.get_child_count(), 4)
	var more := _row.get_child(1) as Control
	assert_eq(more.get_child_count(), 2)
	assert_eq(((more.get_child(0) as Control).get_child(1) as Label).text, "grid")
	assert_eq(((more.get_child(1) as Control).get_child(1) as Label).text, "far")
	assert_eq((_row.get_child(2) as Label).text, "y")
	for file: String in DirAccess.get_files_at(folder):
		DirAccess.remove_absolute("%s/%s" % [ProjectSettings.globalize_path(folder), file])
	DirAccess.remove_absolute(ProjectSettings.globalize_path(folder))

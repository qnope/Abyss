extends TestCase
## What the review board's grid wears besides its floor: the fog's clouds on
## the cells not seen and its wisps off the edge of the seen patch, and the
## backdrop of the level.

const GridCover := preload("res://tool/models/grid_cover.gd")
const GridLayout := preload("res://tool/models/grid_layout.gd")

var _floor: Node3D


func before_each() -> void:
	_floor = Node3D.new()


func after_each() -> void:
	_floor.free()


func test_a_board_all_seen_has_no_fog() -> void:
	GridCover.dress(_floor, 10, false, 1)
	for child in _floor.get_children():
		assert_false(child is MultiMeshInstance3D)


func test_a_fogged_board_has_a_cloud_on_each_cell_not_seen() -> void:
	GridCover.dress(_floor, 10, true, 2)
	var hidden := 0
	for y in 10:
		for x in 10:
			if not GridLayout.seen(x, y, 10):
				hidden += 1
	var clouds := 0
	for child in _floor.get_children():
		if child is MultiMeshInstance3D:
			clouds += (child as MultiMeshInstance3D).multimesh.instance_count
	assert_true(clouds >= hidden, "a cloud on each hidden cell, a wisp off the edge")
	assert_true(clouds < hidden * 2)


func test_the_backdrop_surrounds_the_board() -> void:
	GridCover.dress(_floor, 10, false, 3)
	var pieces := 0
	for child in _floor.get_children():
		if child is MeshInstance3D:
			pieces += 1
	assert_true(pieces >= 24, "edges and corners, then the silhouettes")


func test_a_level_without_backdrop_is_dressed_without_it() -> void:
	GridCover.dress(_floor, 10, false, 9)
	assert_eq(_floor.get_child_count(), 0)

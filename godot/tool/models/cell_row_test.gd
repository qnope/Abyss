extends TestCase
## Models laid out on the cells of a map (the review board's row of what
## stands on the cells): where each goes, how a name tints or dims it.

const CellRow := preload("res://tool/models/cell_row.gd")

var _nodes: Array[Node] = []


func after_each() -> void:
	for node in _nodes:
		node.free()
	_nodes.clear()


func test_contents_fill_rows_of_at_most_the_given_width() -> void:
	var spans: Array[int] = [1, 1, 1, 1, 1]
	assert_eq(CellRow.layout(spans, 3), [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1)])


func test_a_wide_content_takes_its_cells_and_makes_its_row_as_high() -> void:
	var spans: Array[int] = [1, 2, 1, 1]
	assert_eq(CellRow.layout(spans, 4), [Vector2i(0, 0), Vector2i(1, 0), Vector2i(3, 0), Vector2i(0, 2)])


func test_a_content_wider_than_the_row_stands_alone_on_one() -> void:
	var spans: Array[int] = [1, 2]
	assert_eq(CellRow.layout(spans, 1), [Vector2i(0, 0), Vector2i(0, 1)])


func test_the_volcano_covers_two_cells_a_side_and_the_rest_one() -> void:
	assert_eq(CellRow.span_of("map_kernel"), 2)
	assert_eq(CellRow.span_of("map_kernel@69f0ae"), 2)
	assert_eq(CellRow.span_of("map_wreck!"), 1)


func test_the_models_stand_on_the_centre_of_their_cell_the_volcano_on_its_four() -> void:
	var small := Node3D.new()
	var big := Node3D.new()
	var spans: Array[int] = [1, 2]
	var models: Array[Node3D] = [small, big]
	var row := CellRow.new(models, spans, 4)
	_nodes.append(row)
	assert_eq(row.size, Vector2i(3, 2))
	assert_eq(small.position, MapGrid.at(0, 0, 3, 2))
	assert_true(big.position.is_equal_approx(MapGrid.at(1, 0, 3, 2) + Vector3(1, 0, 1) * MapGrid.CELL / 2.0))
	assert_eq(row.cells, [Vector2i(0, 0), Vector2i(1, 0)])


func test_tint_gives_the_node_named_tint_a_lit_material_of_the_colour() -> void:
	var model := Node3D.new()
	_nodes.append(model)
	assert_false(CellRow.tint(model, Color.RED))
	var node := MeshInstance3D.new()
	node.name = "Tint"
	model.add_child(node)
	assert_true(CellRow.tint(model, Color.RED))
	var material := node.material_override as StandardMaterial3D
	assert_eq(material.emission, Color.RED)
	assert_true(material.emission_enabled)


func test_names_load_the_models_tinted_or_dimmed() -> void:
	var models := CellRow.load_models(PackedStringArray(["map_faille@69f0ae", "map_wreck!", "map_ruins"]))
	assert_eq(models.size(), 3)
	_nodes.append_array(models)
	var tint := models[0].get_node("Tint") as MeshInstance3D
	assert_eq((tint.material_override as StandardMaterial3D).emission, Color("69f0ae"))
	for mesh: Node in models[1].find_children("*", "MeshInstance3D", true, false):
		assert_not_null((mesh as MeshInstance3D).material_overlay)
	for mesh: Node in models[2].find_children("*", "MeshInstance3D", true, false):
		assert_null((mesh as MeshInstance3D).material_overlay)


func test_an_unknown_model_loads_none() -> void:
	assert_eq(CellRow.load_models(PackedStringArray(["map_wreck", "nothing_here"])).size(), 0)


func test_the_camera_fits_the_whole_grid_at_the_maps_view() -> void:
	var spans: Array[int] = [1, 1, 1, 1, 1, 1]
	var models: Array[Node3D] = []
	for _i in spans:
		models.append(Node3D.new())
	var row := CellRow.new(models, spans, 3)
	_nodes.append(row)
	var camera := MapCamera.new()
	_nodes.append(camera)
	row.frame(camera, 2.0)
	assert_true(camera.pan.distance > 0.0)
	assert_eq(camera.pan.goal_distance, camera.pan.distance)
	assert_eq(camera.keep_aspect, Camera3D.KEEP_HEIGHT)
	row.frame(camera, 0.5)
	assert_eq(camera.keep_aspect, Camera3D.KEEP_WIDTH)

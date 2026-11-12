extends MapTestCase
## The backdrop round the slab and the creature that swims by.


func test_the_rim_runs_along_each_side_with_a_piece_every_two_cells() -> void:
	assert_eq(MapBackdrop.edge_places(6, 4).size(), 3 + 2 + 3 + 2)
	assert_eq(MapBackdrop.edge_places(5, 5).size(), 12)
	assert_eq(MapBackdrop.corner_places(6, 4).size(), 4)
	var middle := MapBackdrop.edge_places(6, 4)[1]
	assert_true(middle.origin.is_equal_approx(Vector3(0.0, 0.0, 2.0)))
	var corner := MapBackdrop.corner_places(6, 4)[0]
	assert_true(corner.origin.is_equal_approx(Vector3(3.0, 0.0, 2.0)))


func test_the_west_side_turns_the_pieces_a_quarter() -> void:
	var places := MapBackdrop.edge_places(6, 4)
	var west := places[3]
	assert_true(west.origin.is_equal_approx(Vector3(-3.0, 0.0, -1.0)))
	assert_true((west.basis * Vector3.BACK).is_equal_approx(Vector3.LEFT))


func test_dresses_a_level_with_its_pieces_and_its_silhouettes() -> void:
	var backdrop := MapBackdrop.new()
	add_cleanup(backdrop.free)
	backdrop.show_level(1, 8, 6)
	var names: Array[String] = []
	for child in backdrop.get_children():
		names.append(String(child.name))
	assert_eq(names, ["Edge1", "Edge2", "Corner", "Kelp", "Outcrop"])
	backdrop.show_level(3, 8, 6)
	assert_true(backdrop.get_node("Corner") != null)
	assert_eq(backdrop.get_child_count(), 5)


func test_a_creature_swims_round_the_slab_facing_where_it_goes() -> void:
	var ambient := MapAmbient.new()
	mounted(ambient)
	ambient.show_level(2, 8, 6)
	var start := ambient.creature.position
	assert_almost_eq(start.x, 4.0 + MapAmbient.ROOM, 1e-4)
	assert_almost_eq(start.y, MapAmbient.HEIGHT, 1e-5)
	ambient.advance(MapAmbient.LAP / 4.0)
	assert_almost_eq(ambient.creature.position.z, 3.0 + MapAmbient.ROOM, 1e-3)
	var forward := ambient.creature.transform.basis * Vector3.FORWARD
	assert_true(forward.x < -0.9)
	ambient.advance(MapAmbient.LAP / 4.0)
	assert_true(ambient.creature.position.x < 0.0)


func test_the_creature_changes_with_the_level_and_plays_its_swim() -> void:
	var ambient := MapAmbient.new()
	mounted(ambient)
	ambient.advance(1.0)
	assert_null(ambient.creature)
	ambient.show_level(1, 6, 6)
	var turtle := ambient.creature
	var animator := ModelAnimator.new(turtle)
	assert_true(animator.has_animation(&"swim"))
	ambient.show_level(3, 6, 6)
	assert_ne(ambient.creature, turtle)
	ambient._process(0.5)
	assert_eq(ambient.get_child_count(), 1)

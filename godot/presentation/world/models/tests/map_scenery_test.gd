extends TestCase
## The map's floor, fog, backdrop and creatures, as the game takes their parts.


func test_a_level_picks_its_model_and_the_deepest_serves_the_rest() -> void:
	assert_eq(MapScenery.index_of(1), 0)
	assert_eq(MapScenery.index_of(3), 2)
	assert_eq(MapScenery.index_of(7), 2)
	assert_eq(MapScenery.index_of(0), 0)
	assert_eq(MapScenery.TERRAINS.size(), MapScenery.LEVELS)
	assert_eq(MapScenery.BACKDROPS.size(), MapScenery.LEVELS)
	assert_eq(MapScenery.CREATURES.size(), MapScenery.LEVELS)


func test_a_floor_has_three_lit_tiles_and_two_under_the_fog() -> void:
	for scene: PackedScene in MapScenery.TERRAINS:
		var parts := MapScenery.parts(scene)
		assert_eq(MapScenery.named(parts, "Lit").size(), 3)
		assert_eq(MapScenery.named(parts, "Fog").size(), 2)
		for mesh: Mesh in parts.values():
			assert_not_null(mesh)


func test_the_fog_has_its_clouds_and_a_backdrop_its_pieces() -> void:
	assert_eq(MapScenery.named(MapScenery.parts(MapScenery.FOG), "Cloud").size(), 3)
	for scene: PackedScene in MapScenery.BACKDROPS:
		var parts := MapScenery.parts(scene)
		assert_eq(MapScenery.named(parts, "Edge").size(), 2)
		assert_true(parts.has(&"Corner"))

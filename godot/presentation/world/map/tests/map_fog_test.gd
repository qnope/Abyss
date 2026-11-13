extends MapTestCase
## The shroud of clouds over the cells not seen.

var _fog := MapFog.new()


func after_each() -> void:
	_fog.free()


func _total() -> int:
	var total := 0
	for count: int in _fog.counts.values():
		total += count
	return total


func _clouded(state: MapLevelState) -> Array[Vector2i]:
	var found: Array[Vector2i] = []
	for look in MapFog.clouded(MapLooks.of(state), state.map.width, state.map.height):
		found.append(look.key())
	return found


func test_a_cloud_stands_on_every_cell_not_seen_near_a_cell_seen() -> void:
	var cells := _clouded(level_of(10, 10, [Vector2i(0, 0), Vector2i(1, 0)]))
	for cell: Vector2i in [Vector2i(2, 0), Vector2i(3, 0), Vector2i(0, 2), Vector2i(3, 2), Vector2i(1, 1)]:
		assert_has(cells, cell)
	assert_false(cells.has(Vector2i(0, 0)), "none over a cell seen")
	assert_false(cells.has(Vector2i(1, 0)))
	assert_false(cells.has(Vector2i(4, 3)), "the band is %d cells deep: this one is far, and odd" % MapFog.BAND)


func test_far_from_what_is_seen_only_every_other_cell_has_one() -> void:
	var cells := _clouded(level_of(10, 10, [Vector2i(0, 0)]))
	assert_has(cells, Vector2i(6, 6))
	assert_has(cells, Vector2i(7, 7))
	assert_has(cells, Vector2i(8, 6))
	assert_false(cells.has(Vector2i(7, 6)))
	assert_false(cells.has(Vector2i(6, 7)))


func test_a_wreck_seen_through_the_fog_has_no_cloud_over_it() -> void:
	var state := level_of(6, 6, [Vector2i(0, 0)])
	put(state, 1, 1, Content.WRECK)
	assert_false(_clouded(state).has(Vector2i(1, 1)))
	assert_true(_clouded(state).has(Vector2i(2, 1)))


func test_the_whole_map_seen_has_no_shroud() -> void:
	_fog.show_looks(MapLooks.of(level_of(6, 6, [], true)), 6, 6)
	assert_eq(_total(), 0)
	assert_eq(_fog.get_child_count(), 0)


func test_the_clouds_are_laid_in_a_layer_each_that_casts_no_shadow() -> void:
	var state := level_of(12, 12, [Vector2i(0, 0)])
	_fog.show_looks(MapLooks.of(state), 12, 12)
	assert_eq(_total(), _clouded(state).size())
	assert_eq(_fog.get_child_count(), _fog.counts.size())
	assert_eq(_fog.counts.size(), 3, "the three clouds are told apart")
	for layer: MultiMeshInstance3D in _fog.get_children():
		assert_eq(layer.cast_shadow, GeometryInstance3D.SHADOW_CASTING_SETTING_OFF)
		assert_eq(layer.multimesh.instance_count, _fog.counts[layer.name])


func test_the_murk_is_blended_without_a_depth_pre_pass_and_takes_no_shadows() -> void:
	var parts := MapScenery.parts(MapScenery.FOG)
	var clouds := MapScenery.named(parts, "Cloud")
	assert_eq(clouds.size(), 3)
	for cloud in clouds:
		assert_eq(parts[cloud].get_surface_count(), 1, cloud)
		var murk := parts[cloud].surface_get_material(0) as BaseMaterial3D
		assert_eq(murk.transparency, BaseMaterial3D.TRANSPARENCY_ALPHA, "no fragment of it is opaque")
		assert_true(murk.disable_receive_shadows)


func test_the_shroud_is_laid_again_in_place_of_the_one_before() -> void:
	var state := level_of(8, 8, [Vector2i(0, 0)])
	_fog.show_looks(MapLooks.of(state), 8, 8)
	var before := _fog.get_child(0)
	state.revealed[Vector2i(4, 4)] = true
	_fog.show_looks(MapLooks.of(state), 8, 8)
	assert_false(is_instance_valid(before), "the layers before are gone")
	assert_eq(_total(), _clouded(state).size())
	var fresh := MapFog.new()
	add_cleanup(fresh.free)
	fresh.show_looks(MapLooks.of(state), 8, 8)
	assert_eq(laid(_fog), laid(fresh))
	assert_eq(_fog.counts, fresh.counts)


func test_the_same_shroud_again_keeps_its_layers() -> void:
	var state := level_of(8, 8, [Vector2i(0, 0)])
	put(state, 5, 5, Content.WRECK)
	_fog.show_looks(MapLooks.of(state), 8, 8)
	var layers := _fog.get_children()
	var counts := _fog.counts.duplicate()
	_fog.show_looks(MapLooks.of(state), 8, 8)
	assert_eq(_fog.get_children(), layers, "the very layers laid first")
	assert_eq(_fog.counts, counts)


func test_a_wreck_searched_or_a_map_of_another_size_relays_the_shroud() -> void:
	var state := level_of(8, 8, [Vector2i(0, 0)])
	put(state, 6, 6, Content.WRECK)
	_fog.show_looks(MapLooks.of(state), 8, 8)
	var before := _total()
	put(state, 6, 6, Content.EMPTY)
	_fog.show_looks(MapLooks.of(state), 8, 8)
	assert_eq(_total(), before + 1, "a cloud where the wreck showed through")
	var wide := level_of(10, 8, [Vector2i(0, 0)])
	_fog.show_looks(MapLooks.of(wide), 10, 8)
	assert_eq(_total(), _clouded(wide).size())
	assert_true(_total() > before + 1)

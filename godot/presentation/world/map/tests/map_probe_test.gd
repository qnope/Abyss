extends MapTestCase
## The probe the tests of the map's contents ask with.


func test_tells_an_emptied_content_from_a_whole_one_in_a_model_and_a_stand_in() -> void:
	var none: Dictionary[MapContent.Kind, PackedScene] = {}
	assert_false(MapProbe.is_dimmed(mounted(WorldModels.map_content(Kind.RUINS))))
	assert_true(MapProbe.is_dimmed(mounted(WorldModels.map_content(Kind.RUINS, null, true))))
	assert_false(MapProbe.is_dimmed(mounted(WorldModels.map_content(Kind.RUINS, null, false, none))))
	assert_true(MapProbe.is_dimmed(mounted(WorldModels.map_content(Kind.RUINS, null, true, none))))


func test_tells_the_colour_of_a_held_content_in_a_model_and_a_stand_in() -> void:
	var none: Dictionary[MapContent.Kind, PackedScene] = {}
	assert_eq(MapProbe.tint_of(mounted(WorldModels.map_content(Kind.FAILLE, Color.CYAN))), Color.CYAN)
	assert_eq(MapProbe.tint_of(mounted(WorldModels.map_content(Kind.FAILLE, Color.CYAN, false, none))), Color.CYAN)
	assert_true(MapProbe.tint_of(mounted(WorldModels.map_content(Kind.FAILLE))) != Color.CYAN)

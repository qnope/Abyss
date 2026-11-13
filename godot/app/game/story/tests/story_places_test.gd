extends StoryCase
## lib/presentation/screens/game/story/story_places.dart: where the places fought
## over stand on the maps.


func test_the_volcano_of_a_map_without_one_is_nowhere() -> void:
	assert_null(StoryPlaces.kernel_of(null, "me"))
	var map: GameMap = game.levels[1]
	assert_null(StoryPlaces.kernel_of(map, "me"))


func test_the_volcano_is_found_by_its_anchor() -> void:
	var at := find(VOLCANO, CellContentType.Value.VOLCANIC_KERNEL)
	assert_eq(StoryPlaces.kernel_of(game.levels[VOLCANO], "me"), at)


func test_the_volcano_the_player_holds_is_the_one_told() -> void:
	var map: GameMap = game.levels[VOLCANO]
	var at := find(VOLCANO, CellContentType.Value.VOLCANIC_KERNEL)
	var held := map.cell_at(at.x, at.y)
	map.set_cell(at.x, at.y, held.copy_with({"collected_by": "me"}))
	assert_eq(StoryPlaces.kernel_of(map, "me"), at)
	assert_eq(StoryPlaces.kernel_of(map, "someone"), at, "else the first one")


func test_a_post_is_found_by_its_name_with_its_level() -> void:
	var at := find(1, CellContentType.Value.TRANSITION_BASE)
	var base := game.levels[1].cell_at(at.x, at.y).transition_base
	assert_eq(StoryPlaces.post_of(game, base.base_name()), Vector3i(1, at.x, at.y))


func test_a_post_no_map_holds_is_nowhere() -> void:
	var nowhere := TransitionBaseName.new(TransitionBaseType.Value.CHEMINEE, 7)
	assert_null(StoryPlaces.post_of(game, nowhere))

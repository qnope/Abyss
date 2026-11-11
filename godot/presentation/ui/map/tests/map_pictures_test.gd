extends RivalGameCase
## The pictures of the map's sheets: a rival's emblem and the arrival of a passage.


func test_every_faction_has_an_emblem_in_the_assets() -> void:
	for personality: FactionPersonality.Value in FactionPersonality.Value.values():
		assert_true(ResourceLoader.exists(RivalEmblem.path_of(personality)), str(personality))
	assert_eq(RivalEmblem.path_of(FactionPersonality.Value.PEARL_ORDER),
		"res://assets/icons/factions/pearl_order.svg")


func _passage_over(post: TransitionBase) -> Portrait:
	start({Vector2i(2, 2): cell_of(Content.TRANSITION_BASE, {"transition_base": post})})
	return PassagePicture.of(_with_depths(), 2, 2, 2)


## Adds the second level to the game, a passage at (2, 2) on it.
func _with_depths() -> Game:
	var below := MapSamples.plain_map(SIZE, SIZE)
	below.set_cell(2, 2, cell_of(Content.PASSAGE, {"passage_name": "faille:0"}))
	game.levels[2] = below
	return game


func _tint(picture: Portrait) -> Color:
	add_cleanup(picture.free)
	return picture.initials_label.get_theme_color(&"font_color")


func test_the_passage_is_lit_by_whoever_holds_the_post_above() -> void:
	var post := TransitionBase.new(TransitionBaseType.Value.FAILLE, "faille:0")
	assert_eq(_tint(_passage_over(post)), AbyssColors.ON_SURFACE_DIM)
	post.captured_by = "me"
	assert_eq(_tint(_passage_over(post)), AbyssColors.BIOLUM_CYAN)
	post.captured_by = "a rival"
	assert_eq(_tint(_passage_over(post)), AbyssColors.BIOLUM_PINK)


func test_a_passage_with_no_level_above_is_guarded() -> void:
	start({Vector2i(2, 2): cell_of(Content.PASSAGE)})
	var picture := PassagePicture.of(game, 1, 2, 2)
	assert_eq(_tint(picture), AbyssColors.ON_SURFACE_DIM)
	assert_eq(picture.display_name, Texts.t(&"screenUnknownPassage"))


func test_a_passage_under_a_cell_without_a_post_is_guarded() -> void:
	start()
	assert_eq(_tint(PassagePicture.of(_with_depths(), 2, 2, 2)), AbyssColors.ON_SURFACE_DIM)

extends MapTestCase
## test/presentation/widgets/map/map_cell_visual_test.dart,
## map_visuals_builder_test.dart and map_visuals_posts_test.dart, for the looks
## of the cells.

const Holder := PostHolder.Value


func test_has_a_look_for_each_cell_in_the_order_of_the_grid() -> void:
	var looks := MapLooks.of(level_of(4, 3))
	assert_eq(looks.size(), 12)
	assert_eq(looks[5].key(), Vector2i(1, 1))
	assert_eq(looks[11].key(), Vector2i(3, 2))


func test_a_cell_not_seen_is_in_the_fog_and_shows_nothing_of_what_it_holds() -> void:
	var state := level_of(6, 6, [Vector2i(0, 0)])
	put(state, 2, 2, Content.RUINS)
	put(state, 3, 3, Content.MONSTER_LAIR)
	assert_true(look_at(state, 0, 0).revealed)
	assert_false(look_at(state, 2, 2).revealed)
	assert_null(look_at(state, 2, 2).content)
	assert_null(look_at(state, 3, 3).content)


func test_a_cell_seen_shows_its_content() -> void:
	var state := level_of(6, 6, [], true)
	put(state, 1, 1, Content.RESOURCE_BONUS)
	put(state, 2, 1, Content.RUINS)
	put(state, 3, 1, Content.WRECK)
	assert_eq(look_at(state, 1, 1).content, Kind.TREASURE)
	assert_eq(look_at(state, 2, 1).content, Kind.RUINS)
	assert_eq(look_at(state, 3, 1).content, Kind.WRECK)
	assert_null(look_at(state, 4, 4).content)


func test_a_lair_shows_its_difficulty() -> void:
	var state := level_of(6, 6, [], true)
	var lairs: Dictionary[Kind, MonsterDifficulty.Value] = {Kind.LAIR_EASY: MonsterDifficulty.Value.EASY,
		Kind.LAIR_MEDIUM: MonsterDifficulty.Value.MEDIUM, Kind.LAIR_HARD: MonsterDifficulty.Value.HARD}
	var x := 0
	for kind: Kind in lairs:
		put(state, x, 0, Content.MONSTER_LAIR, {"lair": MonsterLair.new(lairs[kind], 3)})
		assert_eq(look_at(state, x, 0).content, kind)
		x += 1
	put(state, 0, 1, Content.MONSTER_LAIR)
	assert_null(look_at(state, 0, 1).content, "a lair with no monsters shows nothing")


func test_collected_content_is_dull() -> void:
	var state := level_of(6, 6, [], true)
	put(state, 1, 1, Content.RUINS, {"collected_by": "someone"})
	put(state, 2, 1, Content.RUINS)
	assert_true(look_at(state, 1, 1).dimmed)
	assert_eq(look_at(state, 1, 1).content, Kind.RUINS)
	assert_false(look_at(state, 2, 1).dimmed)


func test_the_base_shows_the_players_home_only_where_given() -> void:
	var state := level_of(6, 6, [], true)
	state.base = Vector2i(2, 3)
	assert_eq(look_at(state, 2, 3).content, Kind.HOME)
	state.base = null
	assert_null(look_at(state, 2, 3).content)


func test_a_rival_base_wears_its_colour() -> void:
	var state := level_of(6, 6, [], true)
	state.faction_bases[Vector2i(4, 4)] = Color.GOLD
	var look := look_at(state, 4, 4)
	assert_eq(look.content, Kind.FACTION_BASE)
	assert_eq(look.tint, Color.GOLD)


func test_a_post_wears_the_colour_of_who_holds_it() -> void:
	var state := level_of(6, 6, [], true)
	var types: Dictionary[Holder, Variant] = {Holder.GUARDIANS: null, Holder.HUMAN: "me", Holder.FACTION: "them"}
	for holder: Holder in types:
		var base := TransitionBase.new(TransitionBaseType.Value.FAILLE, "Faille", types[holder])
		put(state, holder, 0, Content.TRANSITION_BASE, {"transition_base": base})
		var look := look_at(state, holder, 0)
		assert_eq(look.content, Kind.FAILLE)
		assert_eq(look.tint, MapPalette.HOLDERS[holder])
	var chimney := TransitionBase.new(TransitionBaseType.Value.CHEMINEE, "Cheminée")
	put(state, 0, 2, Content.TRANSITION_BASE, {"transition_base": chimney})
	assert_eq(look_at(state, 0, 2).content, Kind.CHEMINEE)
	put(state, 1, 2, Content.TRANSITION_BASE)
	assert_null(look_at(state, 1, 2).content, "a post cell with no post shows nothing")


func test_a_passage_is_lit_by_the_holder_of_the_post_above() -> void:
	var state := level_of(6, 6, [], true, 2)
	put(state, 1, 1, Content.PASSAGE)
	put(state, 2, 1, Content.PASSAGE)
	state.passage_holders[Vector2i(1, 1)] = Holder.HUMAN
	assert_eq(look_at(state, 1, 1).content, Kind.PASSAGE)
	assert_eq(look_at(state, 1, 1).tint, MapPalette.HOLDERS[Holder.HUMAN])
	assert_eq(look_at(state, 2, 1).tint, MapPalette.HOLDERS[Holder.GUARDIANS])


func test_a_wreck_not_searched_shows_through_the_fog() -> void:
	var state := level_of(6, 6)
	put(state, 1, 1, Content.WRECK)
	put(state, 2, 1, Content.WRECK, {"collected_by": "me"})
	assert_eq(look_at(state, 1, 1).content, Kind.WRECK)
	assert_true(look_at(state, 1, 1).beacon)
	assert_false(look_at(state, 1, 1).revealed)
	assert_null(look_at(state, 2, 1).content, "a wreck searched is gone")
	assert_false(look_at(state, 2, 1).beacon)


func test_the_volcano_is_whole_as_soon_as_one_of_its_cells_is_seen() -> void:
	var state := level_of(6, 6, [Vector2i(3, 3)])
	put(state, 2, 2, Content.VOLCANIC_KERNEL)
	for part: Vector2i in [Vector2i(3, 2), Vector2i(2, 3), Vector2i(3, 3)]:
		put(state, part.x, part.y, Content.VOLCANIC_KERNEL_PART)
	for part in VolcanicKernelPlacer.footprint(2, 2):
		assert_true(look_at(state, part.x, part.y).revealed, str(part))
	assert_eq(look_at(state, 2, 2).content, Kind.KERNEL)
	assert_eq(look_at(state, 2, 2).span, 2)
	assert_null(look_at(state, 3, 3).content, "its parts show nothing of their own")
	assert_false(look_at(state, 4, 4).revealed)
	assert_true(state.revealed.has(Vector2i(3, 3)) and not state.revealed.has(Vector2i(2, 2)),
		"the state's own cells are left as they were")


func test_a_held_volcano_wears_its_owners_seal_and_is_never_dull() -> void:
	var state := level_of(6, 6, [], true)
	put(state, 2, 2, Content.VOLCANIC_KERNEL)
	assert_null(look_at(state, 2, 2).tint)
	put(state, 2, 2, Content.VOLCANIC_KERNEL, {"collected_by": "me"})
	state.owner_colors["me"] = Color.CYAN
	assert_eq(look_at(state, 2, 2).tint, Color.CYAN)
	assert_false(look_at(state, 2, 2).dimmed)

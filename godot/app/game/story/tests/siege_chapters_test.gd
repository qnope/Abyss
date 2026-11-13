extends StoryCase
## lib/presentation/screens/game/story/attack_chapter.dart and turn_story.dart:
## the sieges a turn tells, each on its level, with who held and what each round
## dealt and took.

var _base: Vector2i


func before_each() -> void:
	super()
	_base = Vector2i(human.base_x, human.base_y)


## The kind of figure the attackers of [param chapter] are made of, freed.
func _figure(chapter: StoryChapter) -> Node3D:
	var figure: Node3D = chapter.siege.attacker.call()
	add_cleanup(figure.free)
	return figure


func test_a_raid_besieges_the_base_and_the_defenders_hold_when_it_is_won() -> void:
	var chapter := SiegeChapters.raid(game, raid(true))
	assert_false(chapter.is_fog())
	assert_eq(chapter.level, 1)
	assert_eq(chapter.siege.place, _base)
	assert_eq(chapter.siege.span, 1)
	assert_true(chapter.siege.victory)
	assert_false(SiegeChapters.raid(game, raid(false)).siege.victory)
	assert_true(_figure(chapter) is MonsterFigure)


func test_the_rounds_of_a_raid_are_the_defenders_own() -> void:
	var chapter := SiegeChapters.raid(game, raid())
	assert_eq(chapter.siege.rounds, [Vector2i(10, 5), Vector2i(7, 3)] as Array[Vector2i])


func test_a_kraken_wave_besieges_the_volcano_across_its_four_cells() -> void:
	var chapter := SiegeChapters.volcano(game, wave())
	assert_eq(chapter.level, VOLCANO)
	assert_eq(chapter.siege.place, find(VOLCANO, CellContentType.Value.VOLCANIC_KERNEL))
	assert_eq(chapter.siege.span, VolcanicKernelPlacer.SIDE)
	assert_eq(chapter.siege.rounds, [Vector2i(10, 5), Vector2i(7, 3)] as Array[Vector2i])


func test_a_wave_on_a_game_without_a_volcano_tells_nothing() -> void:
	game.levels.erase(VOLCANO)
	assert_null(SiegeChapters.volcano(game, wave()))


func test_an_attack_on_the_base_is_held_when_the_attacker_lost() -> void:
	var chapter := SiegeChapters.attack(game, attack(false))
	assert_eq(chapter.level, 1)
	assert_eq(chapter.siege.place, _base)
	assert_true(chapter.siege.victory, "the defenders held")
	assert_false(SiegeChapters.attack(game, attack(true)).siege.victory)


func test_the_rounds_of_an_attack_are_seen_from_the_side_attacked() -> void:
	var chapter := SiegeChapters.attack(game, attack(false))
	assert_eq(chapter.siege.rounds, [Vector2i(5, 10), Vector2i(3, 7)] as Array[Vector2i])


func test_the_attackers_of_a_faction_are_its_lead_unit_on_a_ring_of_its_colour() -> void:
	var chapter := SiegeChapters.attack(game, attack(true))
	assert_eq(chapter.siege.ring, FactionColors.ANGLER_CULT)
	assert_false(_figure(chapter) is MonsterFigure)


func test_the_guardians_attack_as_a_kraken_on_a_red_ring() -> void:
	var chapter := SiegeChapters.attack(game, attack(true, null))
	assert_eq(chapter.siege.ring, MapPalette.DAMAGE)
	assert_true(_figure(chapter) is MonsterFigure)


func test_an_attack_on_a_post_is_told_on_its_level_and_cell() -> void:
	var at := find(1, CellContentType.Value.TRANSITION_BASE)
	var named := game.levels[1].cell_at(at.x, at.y).transition_base.name
	var chapter := SiegeChapters.attack(game, attack(true, FactionPersonality.Value.ANGLER_CULT, named))
	assert_eq(chapter.level, 1)
	assert_eq(chapter.siege.place, at)
	assert_eq(chapter.siege.span, 1)


func test_an_attack_on_a_post_no_map_holds_tells_nothing() -> void:
	assert_null(SiegeChapters.attack(game, attack(true, null, "cheminee:6")))


func test_an_attack_on_the_volcano_is_told_across_its_four_cells() -> void:
	var chapter := SiegeChapters.attack(game, attack(true, null, AttackHeldKernelAction.KERNEL_CODE))
	assert_eq(chapter.level, VOLCANO)
	assert_eq(chapter.siege.place, find(VOLCANO, CellContentType.Value.VOLCANIC_KERNEL))
	assert_eq(chapter.siege.span, VolcanicKernelPlacer.SIDE)


func test_an_attack_on_a_volcano_no_map_holds_tells_nothing() -> void:
	game.levels.erase(VOLCANO)
	assert_null(SiegeChapters.attack(game, attack(true, null, AttackHeldKernelAction.KERNEL_CODE)))

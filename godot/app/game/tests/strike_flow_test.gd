extends FactionControllerCase
## The fights played on the map before their reports open: the army swims to
## what it attacks and strikes it, and the report is what comes once it is over.


func before_each() -> void:
	super()
	world.map.effects.reduced_motion = false


## The strike on the map, which holds the report back.
func _playing() -> StrikeEffect:
	assert_null(current_modal(), "the report waits for the strike")
	var effect := world.map.effects.current as StrikeEffect
	assert_not_null(effect)
	return effect


func test_a_fight_against_a_lair_plays_its_monsters_and_then_opens_the_report() -> void:
	send(open_selection(), Harpoonist, 2)
	var effect := _playing()
	assert_not_null(effect.monster, "the monsters of the lair come out")
	assert_eq(effect.geometry.target, lair_at)
	assert_true(effect.strike.victory)
	world.map.effects.finish()
	assert_true(current_modal() is FightSummaryPage)


func test_an_assault_on_a_faille_strikes_the_place_the_map_draws() -> void:
	assault(open_assault(), Harpoonist, 150)
	var effect := _playing()
	assert_null(effect.monster)
	assert_eq(effect.geometry.target, faille_at)
	assert_eq(effect.geometry.span, 1)
	world.map.effects.finish()
	assert_true(current_modal() is TransitionFightSummaryPage)


func test_an_assault_on_the_volcano_strikes_the_four_cells_it_covers() -> void:
	assault(open_kernel_assault(), Harpoonist, 150)
	var effect := _playing()
	assert_eq(effect.geometry.span, VolcanicKernelPlacer.SIDE)
	world.map.effects.finish()
	assert_true(current_modal() is KernelFightSummaryPage)


func test_an_attack_on_a_post_a_rival_holds_is_played_too() -> void:
	rival_holds_faille()
	world.map.cell_tapped.emit(1, faille_at.x, faille_at.y)
	press("Attaquer")
	strike(current_modal() as ArmySelection, Harpoonist, 150)
	var effect := _playing()
	assert_eq(effect.geometry.target, faille_at)
	world.map.effects.finish()
	assert_true(current_modal() is BaseAssaultSummaryPage)


func test_an_attack_on_the_volcano_a_rival_holds_is_played_too() -> void:
	rival_holds_kernel(2)
	world.map.cell_tapped.emit(VOLCANO, kernel_at.x, kernel_at.y)
	press("Attaquer")
	strike(current_modal() as ArmySelection, Harpoonist, 150)
	assert_eq(_playing().geometry.span, VolcanicKernelPlacer.SIDE)
	world.map.effects.finish()
	assert_true(current_modal() is BaseAssaultSummaryPage)


func test_an_attack_on_a_rivals_base_is_played_on_its_cell() -> void:
	strike(open_rival_assault(), Harpoonist, 40)
	var effect := _playing()
	assert_eq(effect.geometry.target, Vector2i(rival.base_x, rival.base_y))
	world.map.effects.finish()
	assert_true(current_modal() is BaseAssaultSummaryPage)

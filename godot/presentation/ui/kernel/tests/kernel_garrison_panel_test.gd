extends UiTestCase
## test/presentation/widgets/volcano/kernel_garrison_panel_test.dart: the
## kernel the player holds, its garrison, the next wave and the buttons that
## move the units.

const Harpoonist := UnitType.Value.HARPOONIST
const Guardian := UnitType.Value.GUARDIAN

var _garrisoned := 0
var _withdrawn := 0


func _panel(war: KernelWar, guided := false) -> KernelGarrisonPanel:
	var panel := KernelGarrisonPanel.new(war.human(), guided)
	panel.garrison_requested.connect(func() -> void: _garrisoned += 1)
	panel.withdraw_requested.connect(func() -> void: _withdrawn += 1)
	return mount(panel) as KernelGarrisonPanel


func _war(garrison := KernelWar.SMALL_GARRISON) -> KernelWar:
	var war := KernelWar.new(3, 7, true)
	war.garrison(garrison)
	return war


func test_the_level_the_rampart_and_the_garrison_by_type() -> void:
	var panel := _panel(_war({Harpoonist: 5, Guardian: 2}))
	assert_not_null(find_text("Noyau niveau 3", panel))
	assert_not_null(find_text("Rempart de magma : %s" % RampartTexts.magma(3), panel))
	assert_not_null(find_text("Garnison", panel))
	assert_not_null(find_text(UnitTexts.display_name(Harpoonist), panel))
	assert_not_null(find_text(UnitTexts.display_name(Guardian), panel))
	assert_no_raw_keys(panel)


func test_an_empty_garrison_says_so_and_withdrawing_is_off() -> void:
	var panel := _panel(_war({}))
	assert_not_null(find_text("Aucune unité en garnison.", panel), "the empty message")
	assert_true(panel.withdraw_button.disabled)
	assert_false(panel.garrison_button.disabled)


func test_the_units_of_the_volcano_level_outside_the_garrison_are_counted() -> void:
	var war := _war()
	war.put(war.human(), KernelGarrison.VOLCANO_LEVEL, {Harpoonist: 4})
	var panel := _panel(war)
	assert_not_null(find_text("Hors garnison, au Niveau 3 : 4 unités", panel))
	war.put(war.human(), KernelGarrison.VOLCANO_LEVEL, {})
	panel = _panel(war)
	assert_null(find_text("Hors garnison", panel))


func test_the_next_wave_and_the_levels_lost_are_told() -> void:
	var war := _war()
	war.human().volcano_state.announce(ThreatSamples.wave(), 14)
	war.human().volcano_state.levels_lost = 2
	var panel := _panel(war)
	assert_not_null(find_text("Prochaine vague, à la fin du tour : %s" % MonsterLairTexts.wave_label(ThreatSamples.wave()), panel))
	assert_not_null(find_text("Niveaux perdus face aux vagues : 2", panel))


func test_a_calm_kernel_never_lost_tells_neither() -> void:
	var panel := _panel(_war())
	assert_null(find_text("Prochaine vague, à la fin du tour : %s" % MonsterLairTexts.wave_label(ThreatSamples.wave()), panel))
	assert_null(find_text("Niveaux perdus face aux vagues : 0", panel))


func test_the_buttons_tell_what_the_player_wants() -> void:
	var panel := _panel(_war())
	press("Mettre en garnison")
	press("Retirer")
	assert_eq([_garrisoned, _withdrawn], [1, 1])


func test_the_guide_surrounds_the_garrison_button_only_when_it_asks() -> void:
	assert_false(_panel(_war()).halo.active)
	assert_true(_panel(_war(), true).halo.active)


func test_the_panel_speaks_english() -> void:
	var panel := _panel(_war())
	use_language("en")
	assert_not_null(find_text("Core level 3", panel))
	assert_no_raw_keys(panel)

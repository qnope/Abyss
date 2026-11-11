extends AssaultPlanCase
## test/presentation/widgets/fight/assault_plan_panel_test.dart: the checklist
## and the gauge of the plan of an assault.


func test_titles_the_section() -> void:
	var panel := panel_of(plan(STRONG))
	assert_eq(panel.title_label.text, "PLAN D'ASSAUT")
	assert_no_raw_keys(panel)


func test_the_admiral_check_is_ok_with_the_admirals_sent() -> void:
	var row := panel_of(plan(STRONG)).admiral_row
	assert_eq(row.state, OK)
	assert_eq(row.title_label.text, "Un Amiral dans l'armée")
	assert_eq(row.detail_label.text, "1 Amiral au niveau 1")


func test_the_admiral_check_is_missing_when_one_waits_on_the_level() -> void:
	var row := panel_of(plan({Harpoonist: 10}, AssaultTarget.Value.FAILLE, {Admiral: 2, Harpoonist: 10})).admiral_row
	assert_eq(row.state, MISSING)
	assert_eq(row.detail_label.text, "Ajoute-le : 2 Amiraux au niveau 1")


func test_the_admiral_check_tells_where_to_recruit_one_when_none() -> void:
	var row := panel_of(plan({Harpoonist: 10})).admiral_row
	assert_eq(row.state, MISSING)
	assert_eq(row.detail_label.text, "Recrute-en un à la Caserne niveau 2")


func test_the_cover_check_is_ok_with_guardians() -> void:
	var row := panel_of(plan(STRONG)).covered_row
	assert_eq(row.state, OK)
	assert_eq(row.title_label.text, "L'Amiral est couvert")
	assert_eq(row.detail_label.text, "4 Gardiens prennent les coups pour lui")


func test_the_cover_check_warns_without_any_guardian() -> void:
	var row := panel_of(plan({Admiral: 1, Harpoonist: 30})).covered_row
	assert_eq(row.state, WARNING)
	assert_eq(row.detail_label.text, "Sans Gardien, il prend les coups le premier")


func test_a_strong_army_is_high_on_the_gauge() -> void:
	var panel := panel_of(plan(STRONG))
	assert_eq(panel.army_row.state, OK)
	assert_eq(panel.army_row.title_label.text, "Armée suffisante")
	assert_eq(panel.army_row.detail_label.text, "Elle l'emporte presque toujours")
	assert_eq(panel.gauge.rating_label.text, "Élevées · 19 sur 20")
	assert_almost_eq(panel.gauge.bar.value, 0.95, 1e-9)
	assert_eq(panel.gauge.bar.theme_type_variation, AbyssInputTheme.CHANCE_HIGH)
	assert_eq(panel.gauge.rating_label.get_theme_color(&"font_color"), AbyssColors.SUCCESS)
	assert_eq(panel.gauge.title_label.text, "Chances")


func test_a_borderline_army_is_risky() -> void:
	var panel := panel_of(plan({Admiral: 1, Guardian: 4, Harpoonist: 34}, AssaultTarget.Value.CHEMINEE))
	assert_eq(panel.army_row.state, WARNING)
	assert_eq(panel.army_row.detail_label.text, "Elle peut échouer : ajoute des unités")
	assert_eq(panel.gauge.rating_label.text, "Risquées · 13 sur 20")
	assert_eq(panel.gauge.bar.theme_type_variation, AbyssInputTheme.CHANCE_RISKY)
	assert_eq(panel.gauge.rating_label.get_theme_color(&"font_color"), AbyssColors.WARNING)


func test_a_weak_army_is_low() -> void:
	var panel := panel_of(plan({Admiral: 1, Harpoonist: 2}))
	assert_eq(panel.army_row.state, MISSING)
	assert_eq(panel.army_row.detail_label.text, "Trop faible : ajoute des unités")
	assert_eq(panel.gauge.rating_label.text, "Faibles · 0 sur 20")
	assert_eq(panel.gauge.bar.theme_type_variation, AbyssInputTheme.CHANCE_LOW)
	assert_eq(panel.gauge.rating_label.get_theme_color(&"font_color"), AbyssColors.ERROR)


func test_an_army_without_an_admiral_takes_nothing() -> void:
	var panel := panel_of(plan({Harpoonist: 60}))
	assert_eq(panel.army_row.detail_label.text, "Sans Amiral, rien n'est pris")
	assert_eq(panel.gauge.rating_label.text, "Faibles · 0 sur 20", "out of as many rehearsals as the rest")


func test_the_icons_tell_the_state_in_its_colour() -> void:
	var panel := panel_of(plan({Admiral: 1, Harpoonist: 30}))
	assert_eq(panel.admiral_row.icon.self_modulate, AbyssColors.SUCCESS)
	assert_eq(panel.covered_row.icon.self_modulate, AbyssColors.WARNING)
	assert_eq(panel.admiral_row.icon.icon_path, UiIcon.glyph_path(&"check"))
	assert_eq(panel.covered_row.icon.icon_path, UiIcon.glyph_path(&"warning"))
	assert_not_null(panel.covered_row.icon.texture)
	assert_eq(AssaultCheckRow.glyph_of(MISSING), &"error")
	assert_eq(AssaultCheckRow.color_of(MISSING), AbyssColors.ERROR)


func test_it_follows_the_language() -> void:
	var panel := panel_of(plan(STRONG))
	use_language("en")
	assert_eq(panel.title_label.text, "ASSAULT PLAN")
	assert_eq(panel.gauge.rating_label.text.split(" · ")[0], "High")
	use_language("es")
	assert_no_raw_keys(panel)

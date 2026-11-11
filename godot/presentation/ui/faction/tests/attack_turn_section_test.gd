extends AttackTurnCase
## test/presentation/widgets/turn/attack_turn_section_test.dart,
## held_attack_lines_test.dart and leviathan_report_test.dart: the attacks of
## the factions in the end-of-turn summary.


func test_a_turn_without_an_attack_has_no_attack_section() -> void:
	var result := TurnResult.new([], 3, 4, false)
	assert_eq(AttackSections.of(result), [] as Array[Control])
	_show(result)
	assert_eq(find_type("AttackTurnSection").size(), 0)
	assert_null(find_text("Voir le rapport"))


func test_a_lost_fight_is_a_pillaged_base() -> void:
	var rival := _section(_fought()).lines[0]
	assert_eq(rival.headline.label.text, "%s a attaqué : base pillée" % rival.report.attacker_name)
	assert_eq(rival.headline.icon.icon_path, UiIcon.glyph_path(&"dangerous"))
	assert_eq(rival.headline.label.get_theme_color(&"font_color"), AbyssColors.ERROR)
	assert_eq(rival.losses.size(), 0)
	assert_no_raw_keys()


func test_a_won_defence_is_a_repelled_attack() -> void:
	var line := _section(_fought(AssaultSamples.WALL)).lines[0]
	assert_eq(line.headline.label.text, "%s a attaqué : attaque repoussée" % line.report.attacker_name)
	assert_eq(line.headline.icon.icon_path, UiIcon.glyph_path(&"shield"))
	assert_eq(line.headline.label.get_theme_color(&"font_color"), AbyssColors.SUCCESS)


func test_a_won_attack_that_pillages_nothing_damages_the_base() -> void:
	var line := _section(_reported(_attack(true))).lines[0]
	assert_eq(line.headline.label.text, "Nacre a attaqué : base endommagée")
	assert_eq(line.headline.icon.icon_path, UiIcon.glyph_path(&"warning"))
	assert_eq(line.headline.label.get_theme_color(&"font_color"), AbyssColors.WARNING)


func test_a_post_taken_names_it_and_what_was_lost_with_it() -> void:
	var line := _section(_reported(_attack(true, "faille:1", null, {Harpoonist: 5}))).lines[0]
	var post := TransitionBaseNameTexts.label("faille:1")
	assert_eq(line.headline.label.text, "Nacre a pris ta %s" % post)
	assert_eq(line.headline.icon.icon_path, UiIcon.glyph_path(&"flag"))
	assert_eq(line.losses.size(), 2)
	assert_eq(line.losses[0].label.text, "Module de descente détruit")
	assert_eq(line.losses[1].label.text, "7 unités du niveau 2 perdues")
	assert_eq(line.losses[1].icon.icon_path, UiIcon.glyph_path(&"remove"))


func test_a_post_without_its_passage_loses_no_building() -> void:
	var line := _section(_reported(_attack(true, "cheminee:0", null, {}, false))).lines[0]
	assert_eq(line.losses.size(), 1)
	assert_eq(line.losses[0].label.text, "2 unités du niveau 3 perdues")


func test_the_capsule_of_a_cheminee_is_the_building_lost() -> void:
	var line := _section(_reported(_attack(true, "cheminee:0", null, {Harpoonist: 1}))).lines[0]
	assert_eq(line.losses[0].label.text, "Capsule pressurisée détruite")


func test_a_post_that_held_says_so() -> void:
	var line := _section(_reported(_attack(false, "faille:1"))).lines[0]
	var post := TransitionBaseNameTexts.label("faille:1")
	assert_eq(line.headline.label.text, "Nacre a attaqué ta %s : attaque repoussée" % post)
	assert_eq(line.losses.size(), 0)


func test_the_kernel_down_one_level_loses_the_defenders_killed() -> void:
	var line := _section(_reported(_attack(true, KERNEL, Vector2i(2, 1)))).lines[0]
	assert_eq(line.headline.label.text, "Nacre a attaqué le Noyau : un niveau perdu")
	assert_eq(line.losses.size(), 1)
	assert_eq(line.losses[0].label.text, "2 unités de la garnison perdues")


func test_the_kernel_taken_and_the_kernel_that_held() -> void:
	assert_eq(_section(_reported(_attack(true, KERNEL, Vector2i(2, 0)))).lines[0].headline.label.text,
		"Nacre a pris le Noyau")
	_answers.clear()
	modals().close_top()
	assert_eq(_section(_reported(_attack(false, KERNEL, Vector2i(2, 2)))).lines[0].headline.label.text,
		"Nacre a attaqué le Noyau : attaque repoussée")


func test_the_guardians_of_the_faille_are_named_in_the_language_on() -> void:
	var result := _reported(_attack(true, "faille:1"), LeviathanForce.ATTACKER_NAME)
	var line := _section(result).lines[0]
	assert_eq(line.headline.label.text, "Le Léviathan a pris ta %s" % TransitionBaseNameTexts.label("faille:1"))
	use_language("en")
	assert_true(line.headline.label.text.begins_with("The Leviathan took"))
	use_language("es")
	assert_no_raw_keys()

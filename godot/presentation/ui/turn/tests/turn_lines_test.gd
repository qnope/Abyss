extends UiTestCase
## The lines the confirmation and the summary of a turn are made of
## (test/presentation/widgets/turn/): a resource's change, a coloured line,
## and a section of losses.

const Res := ResourceType.Value


func test_a_resource_line_names_the_resource_and_what_it_made() -> void:
	var line: ResourceChangeLine = mount(ResourceChangeLine.new(Res.CORAL, 8))
	assert_eq(line.name_label.text, "Corail")
	assert_eq(line.amount_label.text, "+8")
	assert_false(line.capped_label.visible)
	assert_eq((find_type("TextureRect", line)[0] as ResourceIcon).type, Res.CORAL)


func test_a_resource_line_tells_what_was_spent_and_a_full_stock() -> void:
	var line: ResourceChangeLine = mount(ResourceChangeLine.new(Res.ENERGY, 18, 8, true))
	assert_eq(line.amount_label.text, "+18/-8")
	assert_true(line.capped_label.visible)
	assert_eq(line.capped_label.text, "(max atteint)")


func test_a_resource_line_has_the_colour_of_its_resource() -> void:
	var line: ResourceChangeLine = mount(ResourceChangeLine.new(Res.ALGAE, 5))
	assert_eq(line.amount_label.get_theme_color(&"font_color"), ResourceColors.of(Res.ALGAE))


func test_a_summary_line_writes_what_it_is_given_in_its_colour() -> void:
	var line: SummaryLine = mount(SummaryLine.new(&"shield", AbyssColors.SUCCESS, Texts.t.bind(&"turnRecruitAvailable")))
	assert_eq(line.label.text, "Recrutement disponible")
	assert_eq(line.label.get_theme_color(&"font_color"), AbyssColors.SUCCESS)
	assert_eq(line.icon.self_modulate, AbyssColors.SUCCESS)


func test_a_summary_line_follows_the_language() -> void:
	var line: SummaryLine = mount(SummaryLine.new(&"explore", AbyssColors.BIOLUM_CYAN,
		Texts.t.bind(&"turnPendingExplorations", {"count": 3})))
	assert_eq(line.label.text, "3 explorations en attente")
	use_language("en")
	assert_eq(line.label.text, "3 pending explorations")


func test_the_deactivated_buildings_are_listed_under_their_warning() -> void:
	var section: LossSection = mount(TurnLosses.deactivated([
		BuildingType.Value.CORAL_MINE, BuildingType.Value.ORE_EXTRACTOR] as Array[BuildingType.Value]))
	assert_eq(section.title_label.text, "Bâtiments désactivés")
	assert_eq(texts(section), PackedStringArray(["Bâtiments désactivés", "Mine de corail", "Extracteur de minerai"]))
	assert_eq(section.line_labels[0].get_theme_color(&"font_color"), AbyssColors.WARNING)


func test_the_lost_units_are_listed_with_how_many_of_each() -> void:
	var section: LossSection = mount(TurnLosses.lost_units({UnitType.Value.GUARDIAN: 3, UnitType.Value.SCOUT: 1}))
	assert_eq(texts(section), PackedStringArray(["Unités perdues", "Gardien: -3", "Éclaireur: -1"]))
	assert_eq(section.title_label.get_theme_color(&"font_color"), AbyssColors.ERROR)


func test_a_section_follows_the_language() -> void:
	var section: LossSection = mount(TurnLosses.lost_units({UnitType.Value.GUARDIAN: 3}))
	use_language("en")
	assert_eq(texts(section), PackedStringArray(["Units lost", "Guardian: -3"]))
	use_language("es")
	assert_no_raw_keys(section)

extends UiTestCase
## test/presentation/widgets/unit/recruitment_section_test.dart.

const Type := UnitType.Value
const Res := ResourceType.Value

var _game: Game
var _human: Player
var _recruits: Array[int] = []


func before_each() -> void:
	_game = GameFactory.new_single_player("Nemo", 1)
	_human = _game.human_player()
	_human.buildings[BuildingType.Value.BARRACKS].level = 1
	for resource: GameResource in _human.resources.values():
		resource.amount = 100


func _show(type := Type.SCOUT) -> RecruitmentSection:
	var section := RecruitmentSection.new(UnitView.of(_game, type, 0))
	mount(section)
	section.recruit_pressed.connect(_recruits.append)
	return section


func test_offers_a_slider_up_to_what_the_stock_pays_for() -> void:
	var section := _show()
	assert_eq(section.slider.max_value, 10.0)
	assert_eq(section.slider.step, 1.0)
	assert_eq(section.slider.value, 0.0)
	assert_no_raw_keys()


func test_the_recruit_button_is_dark_at_zero() -> void:
	var section := _show()
	assert_true(section.button.disabled)
	assert_eq(section.button.text, "Recruter")
	assert_eq(section.quantity_label.text, "0 unité")


func test_moving_the_slider_updates_the_quantity_the_costs_and_the_noise() -> void:
	var section := _show()
	section.slider.value = 4
	assert_eq(section.quantity, 4)
	assert_eq(section.quantity_label.text, "4 unités")
	assert_eq(section.cost_labels[Res.ALGAE].text, "40")
	assert_eq(section.cost_labels[Res.CORAL].text, "20")
	assert_eq(section.noise_row.amount_label.text, "+4")
	assert_false(section.button.disabled)


func test_shows_a_cost_for_each_resource_the_unit_asks_with_its_icon() -> void:
	var section := _show(Type.HARPOONIST)
	assert_eq(section.cost_labels.keys(), [Res.ALGAE, Res.CORAL, Res.ORE])
	var icons := find_type("TextureRect", section)
	assert_eq(icons.size(), 4, "three resources and the noise's glyph")
	for resource: ResourceType.Value in section.cost_labels:
		var label := section.cost_labels[resource]
		assert_eq(label.get_theme_color(&"font_color"), ResourceColors.of(resource))


func test_pressing_recruit_tells_the_quantity() -> void:
	var section := _show()
	section.slider.value = 3
	press("Recruter")
	assert_eq(_recruits, [3] as Array[int])


func test_says_that_the_type_was_recruited_this_turn() -> void:
	_human.recruited_unit_types.append(Type.SCOUT)
	var section := _show()
	var line := find_text("Recrutement déjà effectué ce tour", section)
	assert_not_null(line)
	assert_eq(line.get_theme_color(&"font_color"), AbyssColors.WARNING)
	assert_null(section.slider)


func test_says_that_the_stock_pays_for_none() -> void:
	for resource: GameResource in _human.resources.values():
		resource.amount = 0
	var section := _show()
	assert_not_null(find_text("Ressources insuffisantes", section))
	assert_null(section.slider)
	assert_null(section.button)


func test_a_degraded_barracks_doubles_the_costs() -> void:
	_human.buildings[BuildingType.Value.HEADQUARTERS].level = 1
	var section := _show()
	assert_eq(section.slider.max_value, 5.0)
	section.slider.value = 1
	assert_eq(section.cost_labels[Res.ALGAE].text, "20")


func test_reads_in_english_and_spanish() -> void:
	use_language("en")
	var section := _show()
	assert_eq(section.button.text, "Recruit")
	assert_no_raw_keys()
	use_language("es")
	var spanish := _show()
	assert_eq(spanish.button.text, Texts.t(&"unitRecruit"))
	assert_ne(spanish.button.text, "Recruit")

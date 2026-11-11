extends UiTestCase
## One option of a choice node (tech_option_card_test.dart).

const Status := TechOptionCard.Status

var _chosen := 0


func _card(status: TechOptionCard.Status, enabled := true) -> TechOptionCard:
	var card := TechOptionCard.new(TechBranch.Value.MILITARY, 2, TechOption.Value.A, status, enabled)
	card.choose_pressed.connect(func() -> void: _chosen += 1)
	return mount(card) as TechOptionCard


func test_shows_its_icon_name_and_effect() -> void:
	var card := _card(Status.OPEN)
	assert_eq(card.icon.icon_path, "res://assets/icons/tech/military_2a.svg")
	assert_eq(card.name_label.text, TechNodeTexts.node_name(TechBranch.Value.MILITARY, 2, TechOption.Value.A))
	assert_eq(card.effect_label.text, TechNodeTexts.node_effect(TechBranch.Value.MILITARY, 2, TechOption.Value.A))
	assert_not_null(find_text(card.name_label.text, card))
	assert_no_raw_keys(card)


func test_an_open_option_is_taken_with_its_button() -> void:
	var card := _card(Status.OPEN)
	assert_eq(card.choose_button.text, "Choisir")
	assert_null(card.status_label)
	assert_null(card.icon.material)
	press("Choisir")
	assert_eq(_chosen, 1)


func test_an_open_option_cannot_be_taken_while_the_node_is_blocked() -> void:
	var card := _card(Status.OPEN, false)
	assert_true(card.choose_button.disabled)
	assert_eq(_chosen, 0)


func test_a_taken_option_says_so_and_has_no_button() -> void:
	var card := _card(Status.TAKEN)
	assert_null(card.choose_button)
	assert_eq(card.status_label.text, "Choisi ✓")
	assert_eq(card.status_label.get_theme_color(&"font_color"), AbyssColors.SUCCESS)
	assert_eq((card.get_theme_stylebox(&"panel") as StyleBoxFlat).border_color, AbyssColors.BIOLUM_PINK)
	assert_null(card.icon.material)


func test_a_discarded_option_is_grey_and_says_so() -> void:
	var card := _card(Status.DISCARDED)
	assert_null(card.choose_button)
	assert_eq(card.status_label.text, "Écarté")
	assert_not_null(card.icon.material)
	assert_eq(card.name_label.get_theme_color(&"font_color"), AbyssColors.ON_SURFACE_DIM)
	assert_eq((card.get_theme_stylebox(&"panel") as StyleBoxFlat).border_color, AbyssColors.SURFACE_BRIGHT)

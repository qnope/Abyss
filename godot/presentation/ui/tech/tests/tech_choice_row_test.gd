extends UiTestCase
## The two options of a choice node, face to face (tech_choice_row_test.dart).

const Status := TechOptionCard.Status
const A := TechOption.Value.A
const B := TechOption.Value.B

var _chosen: Array[TechOption.Value] = []


func _row(taken: Variant = null, enabled := true) -> TechChoiceRow:
	var row := TechChoiceRow.new(TechBranch.Value.EXPLORER, 4, taken, enabled)
	row.chosen.connect(_chosen.append)
	return mount(row) as TechChoiceRow


func test_shows_both_options_with_an_or_between() -> void:
	var row := _row()
	assert_eq(row.cards.size(), 2)
	assert_eq(row.cards[A].icon.icon_path, "res://assets/icons/tech/explorer_4a.svg")
	assert_eq(row.cards[B].icon.icon_path, "res://assets/icons/tech/explorer_4b.svg")
	assert_eq(row.get_child(1).get("text"), "ou")
	assert_eq(row.cards[A].status, Status.OPEN)
	assert_eq(row.cards[B].status, Status.OPEN)


func test_tells_the_option_whose_button_was_pressed() -> void:
	var row := _row()
	press(row.cards[B].choose_button)
	press(row.cards[A].choose_button)
	assert_eq(_chosen, [B, A] as Array[TechOption.Value])


func test_a_blocked_node_disables_both_buttons() -> void:
	var row := _row(null, false)
	assert_true(row.cards[A].choose_button.disabled)
	assert_true(row.cards[B].choose_button.disabled)


func test_a_choice_made_shows_the_option_taken_and_the_one_given_up() -> void:
	var row := _row(B)
	assert_eq(row.cards[A].status, Status.DISCARDED)
	assert_eq(row.cards[B].status, Status.TAKEN)
	assert_null(find_text("Choisir"))


func test_follows_the_language() -> void:
	use_language("en")
	var row := _row()
	assert_eq(row.get_child(1).get("text"), "or")
	assert_eq(row.cards[A].choose_button.text, "Choose")
	assert_no_raw_keys(row)

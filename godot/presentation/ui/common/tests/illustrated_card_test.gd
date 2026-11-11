extends UiTestCase
## The dialog of a card with a picture: its illustration, a centred title,
## a few lines, then its actions stacked full width.

var _results: Array = []


func test_shows_the_illustration_title_and_lines() -> void:
	var card := _card()
	assert_eq(card.card_body.title_label.text, "Tempête")
	assert_eq(card.card_body.title_label.theme_type_variation, &"HeadlineSmall")
	assert_eq(card.card_body.title_label.get_theme_color(&"font_color"), AbyssColors.BIOLUM_CYAN)
	assert_eq(card.card_body.title_label.horizontal_alignment, HORIZONTAL_ALIGNMENT_CENTER)
	assert_eq(texts(card), PackedStringArray(["Tempête", "La mer gronde.", "Restez à l'abri."]))
	var line := card.card_body.line_labels[0]
	assert_eq(line.get_theme_color(&"font_color"), AbyssColors.ON_SURFACE_DIM)
	assert_eq(line.horizontal_alignment, HORIZONTAL_ALIGNMENT_CENTER)
	var picture := find_type("TextureRect", card)[0] as UiIcon
	assert_eq(picture.custom_minimum_size, Vector2(160.0, 160.0))
	assert_eq(picture.icon_path, "res://assets/icons/events/storm.svg")


func test_is_a_dialog_in_the_middle() -> void:
	var card := _card()
	assert_eq(card.theme_type_variation, &"DialogPanel")
	assert_eq(card.placement, ModalPanel.Placement.CENTER)
	card.fit(Vector2(390.0, 800.0))
	assert_eq(card.custom_minimum_size.x, 310.0)


func test_stacks_its_actions_full_width_and_ends_with_the_one_pressed() -> void:
	var card := _card()
	card.closed.connect(func(result: Variant) -> void: _results.append(result))
	var ok := card.add_action("Compris", "ok")
	var later := card.add_action("Plus tard", null, &"TextButton")
	assert_eq(card.card_body.actions(), [ok, later] as Array[Button])
	assert_eq(ok.size_flags_horizontal, Control.SIZE_EXPAND_FILL)
	assert_eq(ok.theme_type_variation, &"")
	assert_eq(later.theme_type_variation, &"TextButton")
	press("Compris")
	assert_eq(_results, ["ok"])


func test_the_body_stands_alone_in_a_frame_of_its_own() -> void:
	var picture := UiIcon.new(UiIcon.path_of(&"factions", &"pearl_order"), 160.0)
	var body := mount(IllustratedCardBody.new(picture, "Ordre", PackedStringArray())) as IllustratedCardBody
	var button := Button.new()
	button.text = "Fermer"
	body.add_action(button)
	assert_eq(body.line_labels.size(), 0)
	assert_eq(body.actions(), [button] as Array[Button])
	assert_not_null(find_text("Ordre"))


func test_scrolls_when_taller_than_the_screen() -> void:
	var card := _card()
	for i in 40:
		card.add_action("Action %d" % i)
	card.fit(Vector2(390.0, 800.0))
	assert_true(card.get_combined_minimum_size().y <= 800.0 * AbyssDialog.MAX_HEIGHT_SHARE + 1.0)


func test_a_note_goes_among_the_actions_without_being_one() -> void:
	var card := _card()
	var first := card.add_action("Un")
	var note := card.card_body.add_note("Fermé", AbyssColors.WARNING)
	var second := card.add_action("Deux")
	assert_eq(card.card_body.actions(), [first, second] as Array[Button])
	assert_eq(note.get_index(), first.get_index() + 1)
	assert_eq(note.text, "Fermé")
	assert_eq(note.theme_type_variation, &"BodySmall")
	assert_eq(note.get_theme_color(&"font_color"), AbyssColors.WARNING)
	assert_eq(note.horizontal_alignment, HORIZONTAL_ALIGNMENT_CENTER)


func _card() -> IllustratedCard:
	var picture := UiIcon.new(UiIcon.path_of(&"events", &"storm"), IllustratedCard.ILLUSTRATION_SIZE)
	var card := IllustratedCard.new(picture, "Tempête",
		PackedStringArray(["La mer gronde.", "Restez à l'abri."]))
	mount(card)
	return card

extends TipCase
## test/presentation/widgets/tip/tip_card_test.dart: the card of one tip.


func _card(id: TipId.Value) -> TipCard:
	var card := TipCard.new(tip(id))
	modals().open(card)
	return card


func test_shows_the_title_the_lines_and_got_it() -> void:
	var card := _card(Id.NOISE_GAUGE)
	assert_eq(card.card_body.title_label.text, TipTexts.title(Id.NOISE_GAUGE))
	assert_eq(card.card_body.line_labels.size(), TipTexts.lines(Id.NOISE_GAUGE).size())
	assert_true(card.card_body.line_labels.size() >= 2)
	assert_not_null(find_text("Compris"))


func test_got_it_closes_it() -> void:
	var card := _card(Id.STORM)
	press("Compris")
	assert_true(card.is_closed())
	assert_null(current_modal())


func test_every_tip_has_a_card_with_a_picture_in_the_three_languages() -> void:
	for language: String in ["fr", "en", "es"]:
		use_language(language)
		for each in TipCatalog.all():
			var card := TipCard.new(each)
			assert_false(card.card_body.title_label.text.is_empty(), str(each.id))
			assert_true(card.card_body.line_labels.size() >= 1, str(each.id))
			assert_no_raw_keys(card)
			card.free()

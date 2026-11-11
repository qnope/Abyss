extends TipCase
## test/presentation/widgets/tip/tip_guide_test.dart: the Guide of the tips,
## those seen to open again, the others greyed.


func _guide() -> TipGuide:
	var guide := TipGuide.new(state())
	modals().open(guide)
	return guide


func _row(guide: TipGuide, id: TipId.Value) -> TipGuideRow:
	for row in guide.rows:
		if row.tip.id == id:
			return row
	return null


func test_lists_every_tip_by_section_unseen_ones_as_question_marks() -> void:
	var guide := _guide()
	assert_eq(guide.rows.size(), TipCatalog.all().size())
	for category: TipCategory.Value in TipCategory.Value.values():
		assert_not_null(find_text(TipTexts.category_label(category)))
	for row in guide.rows:
		assert_true(row.disabled)
		assert_eq(row.title_label.text, "???")


func test_a_tip_seen_shows_its_title_and_opens_its_card() -> void:
	state().mark_seen(Id.STORM)
	var guide := _guide()
	var row := _row(guide, Id.STORM)
	assert_false(row.disabled)
	assert_eq(row.title_label.text, TipTexts.title(Id.STORM))
	assert_eq(guide.rows.filter(func(each: TipGuideRow) -> bool: return each.seen).size(), 1)
	press(row)
	assert_true(current_modal() is TipCard)
	assert_eq((current_modal() as TipCard).tip.id, Id.STORM)
	press("Compris")
	assert_true(current_modal() is TipGuide, "back to the Guide")


func test_close_ends_it() -> void:
	var guide := _guide()
	press("Fermer")
	assert_true(guide.is_closed())


func test_speaks_the_three_languages() -> void:
	state().mark_seen(Id.NOISE_GAUGE)
	var guide := _guide()
	assert_eq(guide.title(), "Guide")
	assert_no_raw_keys(guide)
	use_language("es")
	assert_eq(guide.title(), "Guía")
	assert_no_raw_keys(guide)
	use_language("en")
	assert_eq(guide.title(), "Guide")
	assert_no_raw_keys(guide)

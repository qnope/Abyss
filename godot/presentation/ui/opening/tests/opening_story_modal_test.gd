extends UiTestCase
## The opening story told again from the settings, in a dialog the last card
## closes (showOpeningStory).

var _results: Array = []


func test_tells_the_four_cards_of_the_story() -> void:
	var modal := _open()
	assert_eq(modal.pager.pages.size(), 4)
	assert_not_null(find_text("Le Grand Naufrage", modal))
	assert_eq(modal.placement, ModalPanel.Placement.CENTER)


func test_the_last_card_closes_it() -> void:
	var modal := _open()
	for i in 3:
		press("Suivant")
	assert_false(modal.is_closed())
	press("Fermer")
	assert_true(modal.is_closed())
	assert_eq(_results, [null])
	assert_null(current_modal())


func test_skipping_closes_it_from_the_first_card() -> void:
	_open()
	press("Passer")
	assert_null(current_modal())


func test_follows_the_language() -> void:
	var modal := _open()
	use_language("en")
	assert_eq(modal.pager.next_button.text, "Next")


func _open() -> OpeningStoryModal:
	var modal := OpeningStoryModal.new()
	modal.closed.connect(_results.append)
	modals().open(modal)
	return modal

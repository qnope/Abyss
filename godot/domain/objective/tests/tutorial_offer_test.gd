extends TestCase
## test/domain/objective/tutorial_offer_test.dart: when the new game screen
## offers the tutorial checked.


func test_tutorial_offer_checked_by_default_is_checked_when_no_game_was_ever_saved() -> void:
	assert_true(TutorialOffer.checked_by_default([]))


func test_tutorial_offer_checked_by_default_stays_checked_while_no_save_reached_turn_20() -> void:
	assert_true(TutorialOffer.checked_by_default([_saved_at(3), _saved_at(19)]))


func test_tutorial_offer_checked_by_default_is_unchecked_once_a_save_reached_turn_20() -> void:
	assert_false(TutorialOffer.checked_by_default([_saved_at(3), _saved_at(20)]))


func _saved_at(turn: int) -> Game:
	var game := Game.single_player(Player.new("Nemo"))
	game.turn = turn
	return game

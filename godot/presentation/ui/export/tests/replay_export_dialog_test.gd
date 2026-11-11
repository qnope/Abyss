extends UiTestCase
## test/presentation/widgets/common/replay_export_dialog_test.dart: what the
## replay of a game says about itself, and the two ways to take it away.


## A seam that records what it is asked instead of touching the clipboard.
class FakeSharing:
	extends ReplaySharing

	var downloadable := true
	var clipboard := ""
	var copies := 0
	var file_name := ""
	var file_text := ""

	func can_download() -> bool:
		return downloadable

	func copy(text: String) -> void:
		clipboard = text
		copies += 1

	func download(name: String, text: String) -> void:
		file_name = name
		file_text = text


var _sharing := FakeSharing.new()


func before_each() -> void:
	_sharing = FakeSharing.new()


func _game() -> Game:
	return GameFactory.new_single_player("Nemo", 1)


func _dialog(game := _game()) -> ReplayExportDialog:
	var dialog := ReplayExportDialog.new(game, _sharing)
	modals().open(dialog)
	return dialog


func test_describes_the_replay_file_of_a_new_game() -> void:
	var dialog := _dialog()
	assert_eq(dialog.title(), "Exporter la partie")
	assert_true(dialog.summary_label.text.contains("replay-Nemo-tour-1.json"))
	assert_true(dialog.summary_label.text.contains("0 action sur 1 tour joué"))
	assert_true(dialog.summary_label.text.contains("à l'identique"))
	assert_not_null(find_text("Partager le fichier"))
	assert_not_null(find_text("Copier"))
	assert_no_raw_keys(dialog)


func test_counts_the_actions_over_the_turns() -> void:
	var game := _game()
	game.replay.record(1, RecruitUnitAction.new(UnitType.Value.SCOUT, 3))
	game.replay.record(1, RecruitUnitAction.new(UnitType.Value.SCOUT, 1))
	game.replay.record(2, RecruitUnitAction.new(UnitType.Value.SCOUT, 2))
	game.turn = 3
	var dialog := _dialog(game)
	assert_true(dialog.summary_label.text.contains("replay-Nemo-tour-3.json"))
	assert_true(dialog.summary_label.text.contains("3 actions sur 3 tours joués"))


func test_warns_that_a_game_older_than_the_leviathan_return_may_replay_differently() -> void:
	var game := _game()
	game.leviathan_return = null
	var dialog := _dialog(game)
	assert_true(dialog.summary_label.text.contains("pourra différer"))
	assert_false(dialog.summary_label.text.contains("à l'identique"))


func test_copies_the_replay_as_text_and_says_so() -> void:
	var game := _game()
	var dialog := _dialog(game)
	assert_false(dialog.copied_label.visible)
	press("Copier")
	assert_eq(_sharing.clipboard, ReplayExport.to_text(game))
	assert_true(_sharing.clipboard.contains("\"mapSeed\": 1"))
	assert_true(dialog.copied_label.visible)
	assert_eq(dialog.copied_label.text, "Replay copié dans le presse-papiers")
	assert_eq(current_modal(), dialog, "the dialog stays open")


func test_downloads_the_file_and_closes() -> void:
	var game := _game()
	var dialog := _dialog(game)
	press("Partager le fichier")
	assert_eq(_sharing.file_name, "replay-Nemo-tour-1.json")
	assert_eq(_sharing.file_text, ReplayExport.to_text(game))
	assert_true(dialog.is_closed())
	assert_eq(_sharing.copies, 0)


func test_offers_no_file_where_the_platform_cannot_download() -> void:
	_sharing.downloadable = false
	var dialog := _dialog()
	assert_null(dialog.share_button)
	assert_null(find_text("Partager le fichier"))
	assert_not_null(dialog.copy_button)


func test_close_leaves_without_sharing() -> void:
	var dialog := _dialog()
	press("Fermer")
	assert_true(dialog.is_closed())
	assert_eq(_sharing.copies, 0)
	assert_eq(_sharing.file_name, "")


func test_explains_why_an_old_game_cannot_be_exported() -> void:
	var game := _game()
	game.replay = null
	var dialog := _dialog(game)
	assert_true(dialog.summary_label.text.contains("avant l'enregistrement"))
	assert_null(find_text("Partager le fichier"))
	assert_null(find_text("Copier"))
	assert_not_null(find_text("Fermer"))


func test_follows_the_language() -> void:
	var dialog := _dialog()
	press("Copier")
	use_language("en")
	assert_eq(dialog.title(), "Export the game")
	assert_not_null(find_text("Copy", dialog))
	assert_true(dialog.summary_label.text.contains("0 actions over 1 turn"))
	use_language("es")
	assert_no_raw_keys(dialog)

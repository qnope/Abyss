extends TestCase
## test/domain/objective/tip/archive_tips_test.dart, the group "ancients":
## the archive of the Faille.

const Id := TipId.Value
const FAILLE := TransitionBaseType.Value.FAILLE


func test_ancients_once_the_player_holds_a_faille() -> void:
	var held := PostWar.new(FAILLE, 7, true)
	assert_true(ObjectiveSamples.applies(held.game, Id.ANCIENTS))


func test_ancients_not_while_another_holds_it_nor_for_a_cheminee() -> void:
	var war := PostWar.new(FAILLE)
	assert_false(ObjectiveSamples.applies(war.game, Id.ANCIENTS))
	var vent := PostWar.new(TransitionBaseType.Value.CHEMINEE, 7, true)
	assert_false(ObjectiveSamples.applies(vent.game, Id.ANCIENTS))


func test_ancients_also_for_a_faille_captured_once_then_lost() -> void:
	var game := ObjectiveSamples.objective_game()
	game.human_player().add_history_entry(HistorySamples.capture_entry("cheminee:0"))
	assert_false(ObjectiveSamples.applies(game, Id.ANCIENTS))
	game.human_player().add_history_entry(HistorySamples.capture_entry("faille:1"))
	assert_true(ObjectiveSamples.applies(game, Id.ANCIENTS))


## Not in the Dart file: other entries of the history and a capture lost
## are no Faille.
func test_ancients_not_for_other_entries_nor_a_capture_lost() -> void:
	var game := ObjectiveSamples.objective_game()
	game.human_player().add_history_entry(HistorySamples.raid_entry(true))
	var lost := HistorySamples.capture_entry("faille:0")
	lost.captured = false
	game.human_player().add_history_entry(lost)
	assert_false(ObjectiveSamples.applies(game, Id.ANCIENTS))

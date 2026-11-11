extends TestCase
## test/domain/script/script_run_report_test.dart.

var _done := ScriptLogEntry.new(2, "Explorer (3, 4)", true)
var _refused := ScriptLogEntry.new(3, "Recruter 5 UnitType.guardian", false, ActionFailure.Value.NOT_ENOUGH_RESOURCES)


func test_script_log_entry_a_done_action_reads_as_its_turn_and_description() -> void:
	assert_eq(str(_done), "T2 ✓ Explorer (3, 4)")


func test_script_log_entry_a_refused_action_also_tells_why_it_was_refused() -> void:
	assert_eq(str(_refused), "T3 ✗ Recruter 5 UnitType.guardian (notEnoughResources)")


func test_of_without_milestones_reports_none_reached_and_no_raid() -> void:
	var report := ScriptRunReport.of(_game(), "rush", 7, [_done, _refused])

	assert_null(report.milestones.faille_captured)
	assert_null(report.milestones.kernel_captured)
	assert_eq(report.milestones.raids.size(), 0)
	assert_eq(report.to_json()["raids"], [])


func test_of_counts_the_turns_ended_and_the_refused_actions() -> void:
	var report := ScriptRunReport.of(_game(), "rush", 7, [_done, _refused])

	assert_eq(report.status, GameStatus.Value.PLAYING)
	assert_eq(report.turns_played, 3)
	assert_eq(report.failed_actions(), 1)
	assert_false(report.is_defeat())
	assert_false(report.is_victory())


## Not in the Dart file: what a report writes, of the player it is asked
## for, and a victory counted on its turn.
func test_of_writes_the_holdings_of_the_player_by_their_dart_names() -> void:
	var game := GameFactory.new_game("p", 5, Difficulty.Value.NORMAL, false, 0, _pearl_order())
	game.turn = 4
	var rival: Player = game.players["faction-pearlOrder"]
	rival.buildings[BuildingType.Value.HEADQUARTERS].level = 10
	rival.buildings[BuildingType.Value.VOLCANIC_KERNEL].level = 10
	var json := ScriptRunReport.of(game, "rush", 7, [], null, rival.id).to_json()

	assert_eq(json.keys().slice(0, 5), ["script", "seed", "status", "factionWon", "turnsPlayed"])
	assert_eq(json["buildings"]["headquarters"], 10)
	assert_eq(json["baseUnits"]["scout"], 0)
	assert_eq(json["resources"]["algae"], rival.resources[ResourceType.Value.ALGAE].amount)
	assert_eq(json["kernelCaptured"], null)
	game.status = GameStatus.Value.VICTORY
	var won := ScriptRunReport.of(game, "rush", 7, [])
	assert_eq(won.turns_played, 4)
	assert_true(won.is_victory())
	assert_true(won.faction_won)
	assert_false(ScriptRunReport.of(_game(), "rush", 7, []).faction_won)


func _game() -> Game:
	var game := GameFactory.new_single_player("p", 5)
	game.turn = 4
	return game


func _pearl_order() -> Array[FactionPersonality.Value]:
	return [FactionPersonality.Value.PEARL_ORDER]

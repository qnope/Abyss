extends TestCase
## test/domain/reference/reference_milestones_test.dart. Its last test, the
## milestones of a file `ReferenceExporter` writes, waits for the export
## (`reference_exporter.dart`); every committed file's milestones are those
## its replay finds (tool/reference/reference_replay_test.gd).


func _game() -> Game:
	var personalities: Array[FactionPersonality.Value] = [
		FactionPersonality.Value.PEARL_ORDER, FactionPersonality.Value.ANGLER_CULT,
	]
	return GameFactory.new_game("Nemo", 3, Difficulty.Value.NORMAL, false, 0, personalities)


func test_a_game_that_just_started_went_nowhere() -> void:
	assert_eq(ReferenceMilestones.of(_game(), ScriptMilestones.new()), {
		"failleCaptured": null,
		"chemineeCaptured": null,
		"kernelCaptured": null,
		"leviathanStruck": null,
		"leviathanHeld": null,
		"raidsRepelled": 0,
		"raidsLost": 0,
		"wavesRepelled": 0,
		"wavesLost": 0,
		"fallenFactions": 0,
		"winner": null,
	})


func test_tells_the_steps_taken_the_fights_and_who_tamed_the_volcano() -> void:
	var game := _game()
	var rival: Player = game.players["faction-anglerCult"]
	game.human_player().raid_state.record_outcome(true)
	game.human_player().raid_state.record_outcome(true)
	game.human_player().raid_state.record_outcome(false)
	game.human_player().volcano_state.record_outcome(true)
	game.human_player().volcano_state.record_outcome(false)
	game.players["faction-pearlOrder"].saved_fallen = true
	rival.buildings[BuildingType.Value.HEADQUARTERS].level = 10
	rival.buildings[BuildingType.Value.VOLCANIC_KERNEL].level = 10
	var milestones := ScriptMilestones.new()
	milestones.faille_captured = 30
	milestones.cheminee_captured = 45
	milestones.kernel_captured = 60
	milestones.leviathan_struck = 36
	milestones.leviathan_held = true

	assert_eq(ReferenceMilestones.of(game, milestones), {
		"failleCaptured": 30,
		"chemineeCaptured": 45,
		"kernelCaptured": 60,
		"leviathanStruck": 36,
		"leviathanHeld": true,
		"raidsRepelled": 2,
		"raidsLost": 1,
		"wavesRepelled": 1,
		"wavesLost": 1,
		"fallenFactions": 1,
		"winner": "faction-anglerCult",
	})


func test_the_human_who_wins_is_written_human_not_by_its_id() -> void:
	var game := _game()
	game.human_player().buildings[BuildingType.Value.HEADQUARTERS].level = 10
	game.human_player().buildings[BuildingType.Value.VOLCANIC_KERNEL].level = 10

	assert_eq(ReferenceMilestones.of(game, ScriptMilestones.new())["winner"], "human")

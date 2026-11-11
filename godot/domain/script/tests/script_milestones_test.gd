extends TestCase
## test/domain/script/script_milestones_test.dart.


func test_notes_the_first_turn_a_faille_is_held_and_only_the_first() -> void:
	var game := GameFactory.new_single_player("p", 3)
	var milestones := ScriptMilestones.new()
	milestones.observe(game, 4)
	assert_null(milestones.faille_captured)

	var faille: MapCell = null
	for cell: MapCell in game.levels[1].cells:
		if cell.content == CellContentType.Value.TRANSITION_BASE and cell.transition_base.type == TransitionBaseType.Value.FAILLE:
			faille = cell
			break
	faille.transition_base.captured_by = game.human_player_id
	milestones.observe(game, 9)
	milestones.observe(game, 12, game.human_player_id)

	assert_eq(milestones.faille_captured, 9)
	assert_null(milestones.cheminee_captured)
	assert_null(milestones.kernel_captured)


func test_the_runner_records_every_raid_of_the_game() -> void:
	var report := ScriptRunner.new(60).run(IdleScript.new(), 1)
	var raids := report.milestones.raids

	assert_eq(raids.size(), report.raids_lost() + report.raids_repelled())
	assert_true(raids.all(func(r: ScriptRaid) -> bool: return not r.victory and r.monsters > 0))


func test_notes_when_the_guardians_struck_the_faille_back_and_the_outcome() -> void:
	var kept := LeviathanScene.of()
	kept.put(kept.human(), 2, PostWar.WALL)
	var lost := LeviathanScene.of()
	var milestones := ScriptMilestones.new()
	milestones.observe_leviathan(null)
	assert_null(milestones.leviathan_struck)
	assert_null(milestones.leviathan_held)

	LeviathanScene.play_until(kept, LeviathanScene.strike_turn(kept))
	milestones.observe_leviathan(LeviathanScene.end_turn(kept).report)
	assert_eq(milestones.leviathan_struck, LeviathanScene.strike_turn(kept))
	assert_eq(milestones.leviathan_held, true)
	LeviathanScene.play_until(lost, LeviathanScene.strike_turn(lost))
	milestones.observe_leviathan(LeviathanScene.end_turn(lost).report)
	assert_eq(milestones.leviathan_held, false)
	assert_eq(milestones.to_json()["leviathanHeld"], false)


func test_the_careful_bot_holds_the_faille_the_guardians_strike_back() -> void:
	var milestones := ScriptRunner.new(45).run(ScriptLibrary.by_name("conquest"), 1).milestones

	# 3 turns after the capture at the earliest: later when the Module de
	# descente works after it.
	var captured: int = milestones.faille_captured
	var struck: int = milestones.leviathan_struck
	assert_true(struck >= captured + 3, "%d, %d" % [struck, captured])
	assert_eq(milestones.leviathan_held, true)


func test_records_every_kraken_wave_fought_on_the_kernel() -> void:
	var wave := VolcanoWaveFactory.from_kernel_level(2)
	var report := func(victory: bool) -> VolcanoReport:
		return VolcanoReport.new(70, victory, wave, HistorySamples.fight(victory), 2, {}, {}, {}, {})
	var milestones := ScriptMilestones.new()
	milestones.observe_wave(null)
	var won: VolcanoReport = report.call(true)
	var lost: VolcanoReport = report.call(false)
	milestones.observe_wave(won)
	milestones.observe_wave(lost)

	assert_eq(milestones.waves.map(func(w: ScriptRaid) -> bool: return w.victory), [true, false])
	assert_eq(milestones.waves[0].monsters, wave.total_count())
	assert_eq(milestones.waves[0].monster_level, wave.level())
	var json := milestones.to_json()
	assert_eq(json["waves"], [
		{"turn": 70, "monsters": wave.total_count(), "level": wave.level(), "victory": true},
		{"turn": 70, "monsters": wave.total_count(), "level": wave.level(), "victory": false},
	])


## Not in the Dart file: the first turn the kernel is held, and only the
## first.
func test_notes_the_first_turn_the_kernel_is_held() -> void:
	var player := Player.new("p", "p1", 5, 5)
	var cells: Array[MapCell] = [
		MapCell.new(TerrainType.Value.PLAIN, CellContentType.Value.VOLCANIC_KERNEL, null, "p1"),
	]
	var game := Game.new(player.id, {player.id: player}, 1, {3: GameMap.new(cells.size(), 1, cells, 0)})
	var milestones := ScriptMilestones.new()
	milestones.observe(game, 70)
	milestones.observe(game, 71)

	assert_eq(milestones.kernel_captured, 70)


func test_a_batch_tells_how_many_games_reached_a_milestone_and_when() -> void:
	var report := BatchRunner.new(ScriptRunner.new(60)).run(func(_s: int) -> GameScript: return IdleScript.new(), 2, 8)

	var fall := report.milestone(func(r: ScriptRunReport) -> Variant: return r.turns_played if r.is_defeat() else null)
	var earliest: int = report.earliest_defeat()
	assert_eq(fall.games, 2)
	assert_eq(fall.average_turn, float(earliest))
	assert_eq(report.milestone(func(r: ScriptRunReport) -> Variant: return r.milestones.kernel_captured).games, 0)

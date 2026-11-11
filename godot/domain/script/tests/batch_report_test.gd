extends TestCase
## test/domain/script/batch_report_test.dart.


func test_with_no_runs_reports_zeros_instead_of_dividing_by_zero() -> void:
	var report := BatchReport.new([])

	assert_eq(report.games(), 0)
	assert_eq(report.survival_rate(), 0.0)
	assert_eq(report.average_turns(), 0.0)
	assert_eq(report.average_noise(), 0.0)
	assert_null(report.earliest_defeat())


func test_with_no_runs_milestone_has_no_games_and_no_average() -> void:
	var m := BatchReport.new([]).milestone(_faille)

	assert_eq(m.games, 0)
	assert_null(m.average_turn)


func test_over_mixed_runs_counts_games_defeats_and_victories() -> void:
	var report := _mixed()

	assert_eq(report.games(), 4)
	assert_eq(report.defeats(), 2)
	assert_eq(report.victories(), 1)


func test_over_mixed_runs_survival_rate_is_the_share_of_games_not_lost() -> void:
	assert_eq(_mixed().survival_rate(), 0.5)


func test_over_mixed_runs_averages_turns_raids_and_noise_over_every_game() -> void:
	var report := _mixed()

	assert_eq(report.average_turns(), 20.0)
	assert_eq(report.average_raids_lost(), 0.75)
	assert_eq(report.average_raids_repelled(), 1.0)
	assert_eq(report.average_noise(), 25.0)


func test_over_mixed_runs_earliest_defeat_is_the_smallest_defeat_turn() -> void:
	assert_eq(_mixed().earliest_defeat(), 8)


func test_over_mixed_runs_milestone_counts_only_runs_that_reached_it() -> void:
	var m := _mixed().milestone(_faille)

	assert_eq(m.games, 2)
	assert_eq(m.average_turn, 15.0)


func test_over_mixed_runs_to_json_exposes_every_aggregate() -> void:
	assert_eq(_mixed().to_json(), {
		"games": 4, "defeats": 2, "victories": 1, "factionVictories": 0, "survivalRate": 0.5,
		"averageTurns": 20.0, "averageRaidsLost": 0.75, "averageRaidsRepelled": 1.0,
		"averageNoise": 25.0, "earliestDefeat": 8,
	})


func test_runs_list_cannot_be_modified_after_construction() -> void:
	var source: Array[ScriptRunReport] = [_run()]
	var report := BatchReport.new(source)
	source.append(_run())

	assert_eq(report.games(), 1)
	expect_error("read-only")
	report.runs.append(_run())
	assert_eq(report.games(), 1)


static func _mixed() -> BatchReport:
	return BatchReport.new([
		_run(GameStatus.Value.DEFEAT, 12, 30, 2),
		_run(GameStatus.Value.DEFEAT, 8, 10, 1),
		_run(GameStatus.Value.VICTORY, 40, 50, 0, 3, 10),
		_run(GameStatus.Value.PLAYING, 20, 10, 0, 1, 20),
	])


static func _faille(r: ScriptRunReport) -> Variant:
	return r.milestones.faille_captured


static func _run(
	status := GameStatus.Value.PLAYING, turns := 10, noise := 0, raids_lost := 0, raids_repelled := 0,
	faille: Variant = null,
) -> ScriptRunReport:
	var milestones := ScriptMilestones.new()
	milestones.faille_captured = faille
	return ScriptRunReport.new(
		"test", 1, status, GameStatistics.new(turns, 0, 0, 0, raids_repelled, raids_lost), turns, noise,
		{}, {}, {}, [], milestones,
	)

extends TestCase
## test/domain/script/batch_summary_test.dart.


func test_sums_up_a_batch_the_leviathan_and_the_kraken_waves_included() -> void:
	var held := ScriptMilestones.new()
	held.faille_captured = 30
	held.leviathan_struck = 33
	held.leviathan_held = true
	held.waves.append_array([_wave(true), _wave(false)])
	var lost := ScriptMilestones.new()
	lost.faille_captured = 40
	lost.leviathan_struck = 43
	lost.leviathan_held = false

	var lines := BatchSummary.lines_of("conquest", BatchReport.new([
		_run(GameStatus.Value.VICTORY, held), _run(GameStatus.Value.DEFEAT, lost),
	]))

	assert_eq(lines, [
		"Stratégie : conquest, 2 parties",
		"Survie : 50 % (1 défaites, 1 victoires)",
		"Tours joués en moyenne : 90.0",
		"Raids repoussés / perdus en moyenne : 3.0 / 1.0",
		"Bruit total moyen : 100.0",
		"Première défaite : tour 90",
		"Faille prise : 2/2 parties, tour 35.0 en moyenne",
		"Victoire : 1/2 parties, tour 90.0 en moyenne",
		"Léviathan : 2/2 parties, tour 38.0 en moyenne",
		"Module perdu au Léviathan : 1/2 parties, tour 43.0 en moyenne",
		"Vagues du Noyau : 2 combattues, 1 perdues",
	] as Array[String])


## Not in the Dart file: every step of the road, and a batch that never fell
## nor fought a wave.
func test_names_every_step_of_the_road_and_no_defeat() -> void:
	var road := ScriptMilestones.new()
	road.cheminee_captured = 41
	road.kernel_captured = 55

	var lines := BatchSummary.lines_of("plan", BatchReport.new([_run(GameStatus.Value.PLAYING, road)]))

	assert_eq(lines.slice(5), [
		"Première défaite : tour -",
		"Cheminée prise : 1/1 parties, tour 41.0 en moyenne",
		"Noyau pris : 1/1 parties, tour 55.0 en moyenne",
	])


static func _wave(victory: bool) -> ScriptRaid:
	return ScriptRaid.new(80, 6, 4, victory)


static func _run(status: GameStatus.Value, milestones: ScriptMilestones) -> ScriptRunReport:
	return ScriptRunReport.new(
		"conquest", 1, status, GameStatistics.new(90, 0, 0, 0, 3, 1), 90, 100, {}, {}, {}, [], milestones,
	)

extends TestCase
## test/domain/game/defeat_analysis_test.dart: why the base fell to the
## raids, read from the history.

const Advice := DefeatAdvice.Value
const SCOUT := UnitType.Value.SCOUT

var wave := MonsterLair.new(
	MonsterDifficulty.Value.EASY, 30, MonsterFamily.Value.SWARM, MonsterFamily.Value.HUNTER, 10
)


func _raid(turn: int, defenders: Dictionary[UnitType.Value, int], victory := false, surprise := false) -> RaidEntry:
	return RaidEntry.new(
		turn, victory, wave, HistorySamples.fight(victory), {}, {}, defenders, {}, {}, {}, 0, surprise
	)


func _game_with(history: Array[HistoryEntry]) -> Game:
	return Game.single_player(Player.new("Nemo", null, 1, 1, null, null, null, null, [], [], {}, history))


func _turns(analysis: DefeatAnalysis) -> Array:
	return analysis.raids.map(func(r: LostRaid) -> int: return r.turn)


func test_lists_the_three_raids_lost_in_a_row_oldest_first() -> void:
	var analysis := DefeatAnalysis.of(_game_with([
		_raid(5, {}, true), _raid(13, {}), _raid(20, {}, false, true), _raid(29, {}), _raid(43, {}),
	]))
	assert_eq(_turns(analysis), [13, 29, 43])
	assert_eq(analysis.raids[0].wave, wave)


func test_without_any_defender_the_advice_is_to_raise_an_army() -> void:
	var analysis := DefeatAnalysis.of(_game_with([_raid(13, {}), _raid(29, {}), _raid(43, {})]))
	assert_eq(analysis.raids.map(func(r: LostRaid) -> int: return r.defenders), [0, 0, 0])
	assert_eq(analysis.advice, Advice.RAISE_AN_ARMY)


func test_with_too_few_defenders_it_tells_how_many_harpoonists_it_took() -> void:
	var analysis := DefeatAnalysis.of(_game_with([
		_raid(13, {}), _raid(29, {SCOUT: 2}), _raid(43, {UnitType.Value.HARPOONIST: 1}),
	]))
	var last: LostRaid = analysis.raids.back()
	assert_eq(last.defenders, 1)
	assert_eq(analysis.advice, Advice.MORE_DEFENDERS)
	var needed: int = analysis.harpoonists_needed
	assert_true(needed > 1)


func test_with_enough_bodies_but_the_wrong_units_it_names_the_answers() -> void:
	var analysis := DefeatAnalysis.of(_game_with([_raid(13, {}), _raid(29, {}), _raid(43, {SCOUT: 500})]))
	assert_eq(analysis.advice, Advice.COUNTER_THE_FAMILIES)


func test_without_lost_raids_there_is_nothing_to_explain() -> void:
	assert_null(DefeatAnalysis.of(_game_with([_raid(5, {}, true)])))


## Not in the Dart file: what the Dart rules answer, a wave out of reach
## advising no number at all.
func test_answers_as_dart_with_a_wave_out_of_reach_too() -> void:
	var guards := DefeatAnalysis.of(_game_with([
		_raid(1, {}), _raid(2, {}), _raid(3, {}), _raid(4, {UnitType.Value.GUARDIAN: 3}),
	]))
	assert_eq([_turns(guards), guards.advice, guards.harpoonists_needed], [[2, 3, 4], Advice.MORE_DEFENDERS, 18])
	wave = MonsterLair.new(
		MonsterDifficulty.Value.HARD, 40, MonsterFamily.Value.COLOSSUS, MonsterFamily.Value.ARMOURED, 40
	)
	var huge := DefeatAnalysis.of(_game_with([_raid(43, {UnitType.Value.HARPOONIST: 1})]))
	assert_eq([huge.advice, huge.harpoonists_needed], [Advice.MORE_DEFENDERS, null])


## Not in the Dart file: the names of DefeatAdvice, in the Dart order.
func test_defeat_advice_has_the_values_of_dart_in_its_order() -> void:
	assert_eq(
		DartEnum.names(Advice),
		PackedStringArray(["raiseAnArmy", "moreDefenders", "counterTheFamilies"]),
	)

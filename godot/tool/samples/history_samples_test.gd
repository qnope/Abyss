extends TestCase
## The fight and the entries HistorySamples builds, as the Dart helpers do.


func test_a_fight_of_two_turns_won_or_lost() -> void:
	var won := HistorySamples.fight(true)
	assert_true(won.is_victory())
	assert_eq(won.turn_count, 2)
	assert_eq(won.turn_summaries.map(func(s: FightTurnSummary) -> int: return s.crit_count), [0, 1])
	assert_eq([won.initial_monster_count, won.final_monster_count], [4, 0])
	assert_true(won.initial_player_combatants.is_empty())
	var lost := HistorySamples.fight(false, 6, 3)
	assert_false(lost.is_victory())
	assert_eq([lost.initial_monster_count, lost.final_monster_count], [6, 3])


func test_the_entries_of_the_fights() -> void:
	var capture := HistorySamples.capture_entry("Faille Alpha")
	assert_eq([capture.turn, capture.transition_base_name], [6, "Faille Alpha"])
	var raid := HistorySamples.raid_entry(false, true)
	assert_eq([raid.turn, raid.victory, raid.surprise, raid.wave.level()], [11, false, true, 2])
	assert_false(HistorySamples.raid_entry(true).surprise)
	var volcano := HistorySamples.volcano_entry(true)
	assert_eq([volcano.turn, volcano.victory, volcano.kernel_level], [20, true, 2])
	var assault := HistorySamples.base_assault_entry(true, false)
	assert_eq([assault.turn, assault.opponent_name, assault.defending], [14, "Nacre", false])
	assert_eq([assault.rampart_before, assault.rampart_after, assault.headquarters_after], [2, 0, 5])

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
	assert_eq([assault.post_name, assault.passage_destroyed, assault.dead], [null, true, {}])
	var kernel := HistorySamples.base_assault_entry(
		true, true, "volcanicKernel", Vector2i(1, 0), {UnitType.Value.SCOUT: 2}, {UnitType.Value.GUARDIAN: 1}, false
	)
	assert_eq([kernel.post_name, kernel.rampart_before, kernel.rampart_after], ["volcanicKernel", 1, 0])
	assert_eq([kernel.lost_with_post, kernel.dead, kernel.passage_destroyed],
		[{UnitType.Value.SCOUT: 2}, {UnitType.Value.GUARDIAN: 1}, false])


func test_the_fights_and_the_game_of_the_statistics() -> void:
	var fight := HistorySamples.statistics_fight(CombatSide.Value.MONSTER, 4)
	assert_eq([fight.winner, fight.turn_count, fight.initial_monster_count, fight.final_monster_count], [CombatSide.Value.MONSTER, 1, 4, 0])
	var lost := HistorySamples.statistics_combat(false, 2)
	assert_eq([lost.victory, lost.fight_result.winner, lost.lair.unit_count], [false, CombatSide.Value.MONSTER, 3])
	var game := HistorySamples.statistics_game(9, [lost])
	var player := game.human_player()
	assert_eq([game.turn, player.id, player.name, player.history_entries.size()], [9, "p1", "Test", 1])

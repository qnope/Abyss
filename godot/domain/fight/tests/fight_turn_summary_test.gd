extends TestCase
## test/domain/fight/fight_turn_summary_test.dart: what one turn of a fight
## leaves in its report.


func test_fight_turn_summary_constructor_stores_every_field_correctly() -> void:
	var summary := FightTurnSummary.new(3, 7, 2, 15, 9, 4, 2, 18, 6)

	assert_eq(summary.turn_number, 3)
	assert_eq(summary.attacks_played, 7)
	assert_eq(summary.crit_count, 2)
	assert_eq(summary.damage_dealt_by_player, 15)
	assert_eq(summary.damage_dealt_by_monster, 9)
	assert_eq(summary.player_alive_at_end, 4)
	assert_eq(summary.monster_alive_at_end, 2)
	assert_eq(summary.player_hp_at_end, 18)
	assert_eq(summary.monster_hp_at_end, 6)

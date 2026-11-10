extends TestCase
## lib/domain/fight/fight_turn_stats.dart has no Dart test of its own: the
## engine's tests read it through the summaries.


## Not in the Dart tests: a tally starts empty and is filled in place.
func test_starts_empty_and_counts() -> void:
	var stats := FightTurnStats.new()
	assert_eq([stats.attacks, stats.crits, stats.dmg_player, stats.dmg_monster], [0, 0, 0, 0])
	stats.attacks += 1
	stats.crits += 1
	stats.dmg_player += 4
	stats.dmg_monster += 2
	assert_eq([stats.attacks, stats.crits, stats.dmg_player, stats.dmg_monster], [1, 1, 4, 2])

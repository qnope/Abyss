extends TestCase
## test/presentation/widgets/map/effects/strike/strike_round_test.dart, and the
## spec of a strike built from the result of a fight (map_strike_test.dart).


func test_one_round_per_turn_of_the_fight_with_what_both_sides_lost() -> void:
	var fight := StrikeSamples.fight([7, 4], [1, 3])
	assert_eq(StrikeRounds.of(fight), [Vector2i(7, 1), Vector2i(4, 3)] as Array[Vector2i])


func test_no_fight_no_round() -> void:
	assert_eq(StrikeRounds.of(null), [] as Array[Vector2i])
	assert_eq(StrikeRounds.defence_of(null), [] as Array[Vector2i])


func test_a_defence_reads_the_fight_from_the_side_attacked() -> void:
	var fight := StrikeSamples.fight([7, 4], [1, 3])
	assert_eq(StrikeRounds.defence_of(fight), [Vector2i(1, 7), Vector2i(3, 4)] as Array[Vector2i])


func test_a_strike_is_the_fight_of_an_army_against_a_cell() -> void:
	var fight := StrikeSamples.fight([7, 4], [1, 3])
	var strike := MapStrike.fought(Vector2i(2, 5), fight, StrikeSamples.sent(), false)
	assert_eq(strike.target, Vector2i(2, 5))
	assert_eq(strike.rounds.size(), 2)
	assert_false(strike.victory)
	assert_false(strike.is_monster())
	assert_eq(strike.span, 1)


func test_a_strike_on_a_lair_is_told_by_its_monsters() -> void:
	var lair := StrikeSamples.lair(MonsterFamily.Value.HUNTER)
	var result := FightMonsterResult.success(true, StrikeSamples.fight([5], [1]), {}, StrikeSamples.sent(), {}, {}, {})
	var strike := MapStrike.on_lair(Vector2i(1, 1), lair, result)
	assert_true(strike.is_monster())
	assert_eq(strike.lair, lair)
	assert_true(strike.victory)
	assert_eq(strike.sent, StrikeSamples.sent())
	assert_eq(strike.rounds, [Vector2i(5, 1)] as Array[Vector2i])

extends TestCase
## What an army attacking a cell plays.


func test_a_fight_gives_the_rounds_of_its_turns() -> void:
	var fight := StrikeSamples.fight([7, 4], [2, 0])
	var strike := MapStrike.fought(Vector2i(1, 2), fight, StrikeSamples.sent(), true)
	assert_eq(strike.rounds, [Vector2i(7, 2), Vector2i(4, 0)] as Array[Vector2i])
	assert_eq(strike.target, Vector2i(1, 2))
	assert_true(strike.victory)
	assert_false(strike.is_monster())
	assert_eq(strike.span, 1)


func test_an_attack_on_a_lair_is_one_on_monsters() -> void:
	var lair := StrikeSamples.lair(MonsterFamily.Value.HUNTER)
	var result := FightMonsterResult.new(null, false, StrikeSamples.fight([5], [3]), {},
		StrikeSamples.sent())
	var strike := MapStrike.on_lair(Vector2i(4, 4), lair, result)
	assert_true(strike.is_monster())
	assert_false(strike.victory)
	assert_eq(strike.rounds, [Vector2i(5, 3)] as Array[Vector2i])
	assert_eq(strike.sent, StrikeSamples.sent())

extends TestCase
## test/domain/fight/alive_index_test.dart: the alive combatants of one side
## of a fight, indexed for random picks.


func _unit(key: String, alive := true) -> Combatant:
	return _of(CombatSide.Value.PLAYER, key, alive)


func _monster(key: String, alive := true) -> Combatant:
	return _of(CombatSide.Value.MONSTER, key, alive)


func _of(side: CombatSide.Value, key: String, alive: bool) -> Combatant:
	var c := Combatant.new(side, key, 10, 2, 1)
	if not alive:
		c.apply_damage(999)
	return c


func test_alive_index_counts_the_alive_and_lists_them_in_pool_order() -> void:
	var a := _unit("scout")
	var c := _unit("scout")
	var e := _unit("scout")
	var index := AliveIndex.new([a, _unit("scout", false), c, _unit("scout", false), e])

	assert_eq(index.alive(), 3)
	assert_eq(index.nth_alive(0), a)
	assert_eq(index.nth_alive(1), c)
	assert_eq(index.nth_alive(2), e)
	assert_eq(index.pool.size(), 5)


func test_alive_index_tracks_the_alive_taunting_units() -> void:
	var g1 := _unit("guardian")
	var g2 := _unit("guardian")
	var index := AliveIndex.new(
		[_unit("harpoonist"), g1, _unit("guardian", false), _unit("scout"), g2]
	)

	assert_eq(index.taunting(), 2)
	assert_eq(index.nth_taunting(0), g1)
	assert_eq(index.nth_taunting(1), g2)


func test_alive_index_tracks_the_alive_swarm_fish() -> void:
	var s1 := _monster("swarmL1")
	var s2 := _monster("swarmL1")
	var index := AliveIndex.new([s1, _monster("hunterL1"), _monster("swarmL1", false), s2])

	assert_eq(index.swarm(), 2)
	assert_eq(index.taunting(), 0)
	assert_eq(index.nth_swarm(0), s1)
	assert_eq(index.nth_swarm(1), s2)


func test_alive_index_bury_removes_a_fallen_combatant_from_every_count() -> void:
	var g := _unit("guardian")
	var h := _unit("harpoonist")
	var index := AliveIndex.new([_unit("scout"), g, h])

	g.apply_damage(999)
	index.bury(g)

	assert_eq(index.alive(), 2)
	assert_eq(index.taunting(), 0)
	assert_eq(index.nth_alive(1), h)

	index.bury(g)
	assert_eq(index.alive(), 2)


func test_alive_index_bury_removes_a_fallen_fish_from_the_swarm() -> void:
	var s1 := _monster("swarmL1")
	var s2 := _monster("swarmL1")
	var index := AliveIndex.new([s1, s2])

	s1.apply_damage(999)
	index.bury(s1)

	assert_eq(index.swarm(), 1)
	assert_eq(index.nth_swarm(0), s2)


func test_alive_index_nth_alive_except_skips_an_alive_excluded_combatant() -> void:
	var a := _unit("scout")
	var b := _unit("scout")
	var c := _unit("scout")
	var d := _unit("scout")
	var index := AliveIndex.new([a, b, c, d])

	assert_eq(index.alive_except(b), 3)
	assert_eq(index.nth_alive_except(0, b), a)
	assert_eq(index.nth_alive_except(1, b), c)
	assert_eq(index.nth_alive_except(2, b), d)
	assert_eq(index.nth_alive_except(0, a), b)


func test_alive_index_nth_alive_except_does_not_shift_around_a_dead_one() -> void:
	var a := _unit("scout")
	var dead := _unit("scout", false)
	var c := _unit("scout")
	var index := AliveIndex.new([a, dead, c])

	assert_eq(index.alive_except(dead), 2)
	assert_eq(index.nth_alive_except(0, dead), a)
	assert_eq(index.nth_alive_except(1, dead), c)


func test_alive_index_nth_swarm_except_skips_the_excluded_fish_only_while_it_stands() -> void:
	var s1 := _monster("swarmL1")
	var s2 := _monster("swarmL1")
	var s3 := _monster("swarmL1")
	var index := AliveIndex.new([s1, _monster("hunterL1"), s2, s3])

	assert_eq(index.swarm_except(s2), 2)
	assert_eq(index.nth_swarm_except(0, s2), s1)
	assert_eq(index.nth_swarm_except(1, s2), s3)

	s2.apply_damage(999)
	index.bury(s2)
	assert_eq(index.swarm_except(s2), 2)
	assert_eq(index.nth_swarm_except(1, s2), s3)


## Not in the Dart file: a combatant that is not of the pool counts for
## nothing, is skipped by no lookup and is buried without effect; a unit is
## no fish of the swarm, whose family is the first of the enum.
func test_a_stranger_to_the_pool_changes_nothing() -> void:
	var a := _unit("scout")
	var b := _unit("guardian")
	var stranger := _unit("scout")
	var index := AliveIndex.new([a, b])

	assert_eq([index.alive_except(stranger), index.swarm_except(stranger)], [2, 0])
	assert_eq(index.nth_alive_except(1, stranger), b)
	index.bury(stranger)
	assert_eq([index.alive(), index.taunting(), index.swarm()], [2, 1, 0])

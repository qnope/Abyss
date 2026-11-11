extends TestCase
## test/domain/faction/kernel_siege_rules_test.dart: how a faction besieges
## a kernel held high.


## The human wins a siege of the owner's kernel this turn.
static func _human_wins(war: KernelWar) -> void:
	war.put(war.human(), 3, KernelWar.HORDE)
	ActionExecutor.new().execute(war.strike(KernelWar.HORDE), war.game, war.human())


static func _besiege(war: KernelWar, planner: ArmyPlanner = null) -> bool:
	return FactionKernelWar.besiege_hot(
		FactionTurn.new(war.game, war.attacker(), ActionExecutor.new(), DartRandom.new(2, false)),
		planner if planner != null else ArmyPlanner.new(),
	)


static func _won(war: KernelWar) -> int:
	var won := 0
	for e: BaseAssaultEntry in War.assaults(war.owner()):
		if e.defending and e.victory:
			won += 1
	return won


static func _war(difficulty: Difficulty.Value) -> KernelWar:
	var war := KernelWar.new(9)
	war.arm()
	war.garrison(KernelWar.SMALL_GARRISON)
	war.game.saved_difficulty = difficulty
	return war


func test_the_planner_gives_up_0_125_of_confidence_from_level_8() -> void:
	var base := ArmyPlanner.new(8, 0.85)
	assert_eq(KernelSiege.planner_for(base, 7).confidence, 0.85)
	assert_almost_eq(KernelSiege.planner_for(base, 8).confidence, 0.725, 1e-9)
	assert_eq(KernelSiege.planner_for(base, 9).rehearsals, base.rehearsals)
	var bold := ArmyPlanner.new(8, 0.7)
	assert_eq(KernelSiege.planner_for(bold, 9).confidence, 0.625)


func test_at_level_8_it_accepts_a_siege_won_6_times_out_of_8() -> void:
	var war := KernelWar.new(8)
	war.garrison({UnitType.Value.HARPOONIST: 40})
	var boost := FightMonsterHelpers.unit_boost_of(war.attacker(), true)
	var planner := ArmyPlanner.new()
	var defence := func() -> Array[Combatant]: return BaseDefence.kernel(war.owner()).side
	var n := 1
	while n <= 120:
		var rate := planner.win_rate({UnitType.Value.HARPOONIST: n}, defence, boost)
		if rate >= 0.725 and rate < 0.85:
			break
		n += 1
	war.arm({UnitType.Value.HARPOONIST: n})

	assert_true(_besiege(war, planner))
	assert_eq(war.kernel_of(war.owner()), 7)


func test_on_easy_one_won_siege_a_turn_per_holder() -> void:
	var war := _war(Difficulty.Value.EASY)
	_human_wins(war)
	assert_eq(_won(war), 1)

	assert_false(_besiege(war))
	assert_eq(war.kernel_of(war.owner()), 8)


func test_on_normal_and_hard_two_won_sieges_a_turn_per_holder() -> void:
	for d: Difficulty.Value in [Difficulty.Value.NORMAL, Difficulty.Value.HARD]:
		var war := _war(d)
		_human_wins(war)
		assert_false(KernelSiege.is_capped(war.game, war.owner()))

		assert_true(_besiege(war))
		assert_eq(war.kernel_of(war.owner()), 7)
		assert_true(KernelSiege.is_capped(war.game, war.owner()))
	assert_eq(KernelSiege.won_per_turn(Difficulty.Value.EASY), 1)
	assert_eq(KernelSiege.won_per_turn(Difficulty.Value.NORMAL), 2)


func test_a_siege_won_on_an_earlier_turn_does_not_count() -> void:
	var war := _war(Difficulty.Value.EASY)
	_human_wins(war)
	war.game.turn += 1

	assert_true(_besiege(war))


func test_it_never_besieges_the_kernel_it_holds_itself() -> void:
	var war := KernelWar.new(7)
	war.arm()
	var map: GameMap = war.game.levels[3]
	map.set_cell(war.at.x, war.at.y, map.cell_at(war.at.x, war.at.y).copy_with({"collected_by": war.attacker().id}))

	assert_false(_besiege(war))
	assert_eq(War.assaults(war.attacker()).size(), 0)


## Not in the Dart file: the cap alone, which the Dart tests read through
## besiegeHot.
func test_a_holder_is_capped_by_the_sieges_it_lost_this_turn() -> void:
	var easy := _war(Difficulty.Value.EASY)
	easy.owner().history_entries.append(BuildingEntry.new(12, BuildingType.Value.HEADQUARTERS, 2))
	assert_false(KernelSiege.is_capped(easy.game, easy.owner()))
	_human_wins(easy)
	assert_true(KernelSiege.is_capped(easy.game, easy.owner()))
	easy.game.turn += 1
	assert_false(KernelSiege.is_capped(easy.game, easy.owner()), "an earlier turn")
	var normal := _war(Difficulty.Value.NORMAL)
	_human_wins(normal)
	assert_false(KernelSiege.is_capped(normal.game, normal.owner()))
	assert_false(KernelSiege.is_capped(normal.game, normal.human()), "the winner lost nothing")

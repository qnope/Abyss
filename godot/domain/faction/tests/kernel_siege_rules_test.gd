extends TestCase
## test/domain/faction/kernel_siege_rules_test.dart: how a faction besieges
## a kernel held high. Its tests of FactionKernelWar.besiegeHot wait for
## FactionKernelWar (domain/README.md, "Left for a later lot").


## The human wins a siege of the owner's kernel this turn.
static func _human_wins(war: KernelWar) -> void:
	war.put(war.human(), 3, KernelWar.HORDE)
	ActionExecutor.new().execute(war.strike(KernelWar.HORDE), war.game, war.human())


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
